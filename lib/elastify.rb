require "elastify/version"
require "elastify/active_record_extensions"

module Elastify
    
    class << self
        def configure &block
            mappings = {}
            configs = OpenStruct.new({
                base_url: "http://localhost:9200",
                mappings_path: Rails.root.join("config/elastify/mappings")
            })
            block.call(configs) if block_given?
            dir = configs.mappings_path
            if Dir.exist?(dir)
                Dir.glob("#{dir}/*.json") do |file_path|
                    mappings[File.basename(file_path, ".json")] = JSON.parse(File.read(file_path))
                end
            end
            Rails.application.config.elastify = {
                configs: configs,
                mappings: mappings,
            }
        end

        def configs
            return Rails.application.config.elastify[:configs]
        end 

        def mappings
            return Rails.application.config.elastify[:mappings]
        end 
    end
    
    class ElastifyError < StandardError; end
end
