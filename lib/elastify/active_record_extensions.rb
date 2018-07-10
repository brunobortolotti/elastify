require 'active_record'
require 'backgrounded'
require 'elastify'

module Elastify::ActiveRecordExtensions
    extend ActiveSupport::Concern

    module ClassMethods
        extend ActiveSupport::Concern

        def elastify_model(model_name)
            include Elastify::ActiveRecordExtensions::LocalMethods
            cattr_accessor :elastify_options
            attr_accessor :elastify_serialized_document

            model = Elastify.models[model_name.to_sym]
            yield(model) if block_given?
            self.elastify_options = {} if self.elastify_options.blank?
            self.elastify_options[:base_url] = Elastify.configs.base_url
            self.elastify_options[:index] = model.opt_index if model.opt_index.present?
            self.elastify_options[:type] = model.opt_type if model.opt_type.present?
            self.elastify_options[:map] = model.opt_mapping if model.opt_mapping.present?
            self.elastify_options[:decode] = model.opt_decode if model.opt_decode.present?
            self.elastify_options[:encode] = model.opt_encode if model.opt_encode.present?
            self.elastify_options[:scroll_timeout] = model.opt_scroll_timeout if model.opt_scroll_timeout.present?
        end

        def elastify_setup
            include Elastify::ActiveRecordExtensions::LocalMethods
            cattr_accessor :elastify_options
            attr_accessor :elastify_serialized_document

            model = Elastify::Model.new
            yield(model) if block_given?
            self.elastify_options = {} if self.elastify_options.blank?
            self.elastify_options[:base_url] = Elastify.configs.base_url
            self.elastify_options[:index] = model.opt_index if model.opt_index.present?
            self.elastify_options[:type] = model.opt_type if model.opt_type.present?
            self.elastify_options[:map] = model.opt_mapping if model.opt_mapping.present?
            self.elastify_options[:decode] = model.opt_decode if model.opt_decode.present?
            self.elastify_options[:encode] = model.opt_encode if model.opt_encode.present?
            self.elastify_options[:scroll_timeout] = model.opt_scroll_timeout if model.opt_scroll_timeout.present?
        end

        def elastify_search(dsl: nil, scroll_timeout: nil)
            Elastify::Helpers::ElasticSearch::Document.new(self.elastify_options).search(dsl, scroll_timeout)
        end

        def elastify_scroll(scroll_id: nil, scroll_timeout: nil)
            Elastify::Helpers::ElasticSearch::Document.new(self.elastify_options).scroll(scroll_id, scroll_timeout)
        end
    end

    module LocalMethods
        extend ActiveSupport::Concern

        def elastify_create
            run_callbacks(:elastify_sync) do
                unless self.elastify_serialized_document.blank?
                    run_callbacks(:elastify_create) do
                        Elastify::Helpers::ElasticSearch::Document.new(self.class.elastify_options).create(self.elastify_serialized_document)
                    end
                end
            end
        end

        def elastify_update
            run_callbacks(:elastify_sync) do
                unless self.elastify_serialized_document.blank?
                    run_callbacks(:elastify_update) do
                        Elastify::Helpers::ElasticSearch::Document.new(self.class.elastify_options).update(self.elastify_serialized_document)
                    end
                end
            end
        end

        def elastify_destroy
            run_callbacks(:elastify_sync) do
                unless self.elastify_serialized_document.blank?
                    run_callbacks(:elastify_destroy) do
                        Elastify::Helpers::ElasticSearch::Document.new(self.class.elastify_options).destroy(self.elastify_serialized_document)
                    end
                end
            end
        end

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
                if self.class.elastify_options[:encode].present?
                    encoder = self.class.elastify_options[:encode]
                elsif self.respond_to?(:to_serial)
                    encoder = Proc.new { |i| next i.to_serial }
                else
                    encoder = Proc.new { |i| next i.serializable_hash }
                end
                item.elastify_serialized_document = encoder.call(item)
            end
        end
    end
end