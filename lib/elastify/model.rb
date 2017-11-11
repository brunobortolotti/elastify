require 'active_record'
require 'backgrounded'
require 'elastify/elastic_search_helper'
require 'elastify'

module Elastify

    module Model
        extend ActiveSupport::Concern

        cattr_accessor :elastify_mapping
        attr_accessor :elastify_serialized_document

        included do
            define_model_callbacks :elastify_create
            define_model_callbacks :elastify_update
            define_model_callbacks :elastify_destroy
            define_model_callbacks :elastify_sync
            # define_model_callbacks :elastify_serialize

            after_commit on: :create do |item|
                item.elastify_create
            end

            after_commit on: :update do |item|
                item.elastify_update
            end

            after_commit on: :destroy do |item|
                item.elastify_destroy
            end

            before_elastify_sync do |item|
                if self.class.elastify_mapping.map_encode.present?
                    parser = self.class.elastify_mapping.map_encode
                elsif self.respond_to?(:to_serial)
                    parser = Proc.new { |item| next item.to_serial }
                else
                    parser = Proc.new { |item| next item.serializable_hash }
                end
                item.elastify_serialized_document = parser.call(item)
            end
        end

        def elastify_create
            run_callbacks(:elastify_sync) do
                if not self.elastify_serialized_document.blank?
                    run_callbacks(:elastify_create) do
                        ElasticSearchHelper::Document.new(self.class.elastify_options).create(self.elastify_serialized_document)
                    end
                end
            end
        end

        def elastify_update
            run_callbacks(:elastify_sync) do
                if not self.elastify_serialized_document.blank?
                    run_callbacks(:elastify_update) do
                        ElasticSearchHelper::Document.new(self.class.elastify_options).update(self.elastify_serialized_document)
                    end
                end
            end
        end

        def elastify_destroy
            run_callbacks(:elastify_sync) do
                if not self.elastify_serialized_document.blank?
                    run_callbacks(:elastify_destroy) do
                        ElasticSearchHelper::Document.new(self.class.elastify_options).destroy(self.elastify_serialized_document)
                    end
                end
            end
        end

        module ClassMethods
            def elastify_search(dsl: nil, scroll_timer: "1m")
                return ElasticSearchHelper::Document.new(self.elastify_options).search(dsl, scroll_timer)
            end

            def elastify_scroll(scroll_id: nil, scroll_timer: "1m")
                return ElasticSearchHelper::Document.new(self.elastify_options).scroll(scroll_id, scroll_timer)
            end

            def elastify_mapping= mapping
                @elastify_mapping = mapping
            end

            def elastify_mapping
                @elastify_mapping
            end

            def elastify_options
                {
                    base_url: Elastify.configs[:base_url],
                    index: self.elastify_mapping.map_index,
                    type: self.elastify_mapping.map_type,
                    map: self.elastify_mapping.map_mapping
                }
            end
        end
    end
end