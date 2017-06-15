module Elastify 
    module ElasticSearchHelper 
        class Document
            cattr_accessor :options
            def initialize options = {}
                self.options = options
            end
            def create model
                Connector.create(self.options, model)
            end
            def update model
                Connector.update(self.options, model)
            end
            def destroy model
                Connector.destroy(self.options, model)
            end
            def search dsl
                Connector.search(self.options, dsl)
            end
        end
        class Connector
            def self.create(options, data)
                if data.blank?
                    raise :elastify__create__required_data
                end
                if data[:id].blank?
                    raise :elastify__create__required_data_id
                end
                url = "#{options[:base_url]}/#{options[:index]}/#{options[:type]}/#{data[:id]}"
                response = JSON.parse(RestClient.put(url, data.to_json, {}))
            end
            def self.update options, data
                if data.blank?
                    raise :elastify__update__required_data
                end
                if data[:id].blank?
                    raise :elastify__update__required_data_id
                end
                url = "#{options[:base_url]}/#{options[:index]}/#{options[:type]}/#{data[:id]}"
                response = JSON.parse(RestClient.put(url, data.to_json, {})).to_hash
            end
            def self.destroy options, data
                if data.blank?
                    raise :elastify__delete__required_data
                end
                if data[:id].blank?
                    raise :elastify__delete__required_data_id
                end
                url = "#{options[:base_url]}/#{options[:index]}/#{options[:type]}/#{data[:id]}"
                response = JSON.parse(RestClient.delete(url)).to_hash
            end
            def self.search options, dsl 
                if dsl.blank?
                    raise :elastify__search__required_dsl
                end
                url = "#{options[:base_url]}/#{options[:index]}/#{options[:type]}/_search"
                response = SearchResultSet.new(RestClient.post(url, dsl.to_json, {}))
            end
            def self.destroy_type options
                url = "#{options[:base_url]}/#{options[:index]}/#{options[:type]}"
                response = JSON.parse(RestClient.delete(url)).to_hash
            end
        end
        class SearchResultSet
            attr_accessor :took, :timed_out, :shards_total, :shards_successful, :shards_failed, :hits_total, :hits_maxscore, :hits
            def initialize elasticsearch_search_result
                esr = JSON.parse(elasticsearch_search_result)
                self.took = esr["took"]
                self.timed_out = esr["timed_out"]
                self.shards_total = esr["_shards"]["total"]
                self.shards_successful = esr["_shards"]["successful"]
                self.shards_failed = esr["_shards"]["failed"]
                self.hits_total = esr["hits"]["total"]
                self.hits_maxscore = esr["hits"]["maxscore"]
                self.hits = esr["hits"]["hits"].map{ |hit| SearchResult.new(hit) }
            end
        end
        class SearchResult
            attr_accessor :index, :type, :id, :score, :source
            def initialize elasticsearch_search_result_hit
                esrh = elasticsearch_search_result_hit
                self.index = esrh["_index"]
                self.type = esrh["_type"]
                self.id = esrh["_id"]
                self.source = OpenStruct.new(esrh["_source"])
            end
        end
    end
end