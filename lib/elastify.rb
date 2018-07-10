require 'elastify/version'
require 'elastify/config'
require 'elastify/model'
require 'elastify/errors/base'
require 'elastify/errors/bad_request'
require 'elastify/errors/connection'
require 'elastify/configurators/model'
require 'elastify/active_record_extensions'
require 'elastify/helpers/elastic_search/connector'
require 'elastify/helpers/elastic_search/document'
require 'elastify/helpers/elastic_search/search_result'
require 'elastify/helpers/elastic_search/search_result_collection'


module Elastify

    class << self

        def init(&block)
            load_configs(block)
            load_models
        end

        def configs
            Rails.application.config.elastify_configs = Elastify::Config.new unless Rails.application.config.respond_to?(:elastify_configs)
            Rails.application.config.elastify_configs
        end

        def models
            Rails.application.config.elastify_models = {} unless Rails.application.config.respond_to?(:elastify_models)
            Rails.application.config.elastify_models
        end

        def register_model(model_name)
            model = Elastify::Model.new
            yield(model) if block_given?
            models[model_name] = model
        end

        private
            def load_configs(block)
                block.call(configs) if block.present?
            end

            def load_models
                path = Rails.root.join('config/elastify')
                if Dir.exist?(path)
                    Dir.glob("#{path}/*.rb") do |file_path|
                        require file_path
                    end
                end
            end
    end
end
