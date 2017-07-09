require 'active_record'
require 'backgrounded'
require 'elastify/elastic_search_helper'

module Elastify
    module ActiveRecordExtensions
        extend ActiveSupport::Concern

        module ClassMethods
            def elastify elastify_options = {}, &block
                include Elastify::ActiveRecordExtensions::LocalMethods
                cattr_accessor :elastify_options, :elastify_model_block
                attr_accessor :elastify_serialized_document

                self.elastify_options = {
                    base_url: Elastify.defaults[:base_url],
                    index: elastify_options[:index] || Elastify.defaults[:default_index],
                    type: elastify_options[:type] || Elastify.defaults[:default_type],
                    map: elastify_options[:map] || Elastify.defaults[:default_map]
                }

                self.elastify_options.each do |key, value|
                    if value.blank? 
                        raise ElastifyError, "You must specify the #{key} value"
                    end
                end 

                if block_given?
                    self.elastify_model_block = block
                else 
                    self.elastify_model_block = Proc.new { |item|
                        next Hash.new
                    }
                end
            end
        end

        module LocalMethods
            extend ActiveSupport::Concern

            def elastify_create
                run_callbacks(:elastify_sync) do 
                    if not self.elastify_serialized_document.blank?
                        run_callbacks(:elastify_create) do
                            ElasticSearchHelper::Document.new(self.elastify_options).create(self.elastify_serialized_document)
                        end
                    end
                end
            end

            def elastify_update
                run_callbacks(:elastify_sync) do 
                    if not self.elastify_serialized_document.blank?
                        run_callbacks(:elastify_update) do
                            ElasticSearchHelper::Document.new(self.elastify_options).update(self.elastify_serialized_document)
                        end
                    end
                end
            end

            def elastify_destroy 
                run_callbacks(:elastify_sync) do 
                    if not self.elastify_serialized_document.blank?
                        run_callbacks(:elastify_destroy) do
                            ElasticSearchHelper::Document.new(self.elastify_options).destroy(self.elastify_serialized_document)
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

                after_create { |item|
                    item.elastify_create
                }

                after_update { |item|
                    item.elastify_update
                }

                after_destroy { |item|
                    item.elastify_destroy
                }

                before_elastify_sync { |item|
                    item.elastify_serialized_document = self.elastify_model_block.call(item)
                }
            end 

            module ClassMethods
                def elastify_search(dsl: nil, scroll_timer: "1m")
                    return ElasticSearchHelper::Document.new(self.elastify_options).search(dsl, scroll_timer)
                end
                
                def elastify_scroll(scroll_id: nil, scroll_timer: "1m")
                    return ElasticSearchHelper::Document.new(self.elastify_options).scroll(scroll_id, scroll_timer)
                end
            end
        end

    end
end

ActiveRecord::Base.send(:include, Elastify::ActiveRecordExtensions)
