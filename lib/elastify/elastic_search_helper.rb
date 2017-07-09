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
            def search dsl, scroll_timer = nil
                Connector.search(self.options, dsl, scroll_timer)
            end
            def scroll scroll_id, scroll_timer = nil
                Connector.scroll(self.options, scroll_id, scroll_timer)
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
            def self.search options, dsl, scroll_timer
                if dsl.blank?
                    raise :elastify__search__required_dsl
                end
                url = "#{options[:base_url]}/#{options[:index]}/#{options[:type]}/_search"
                url += "?scroll=#{scroll_timer}" if scroll_timer.present?
                puts url
                response = SearchResultSet.new(RestClient.post(url, dsl.to_json, {}))
            end
            def self.scroll options, scroll_id, scroll_timer
                if scroll_id.blank?
                    raise :elastify__search__required_scroll_id
                end
                url = "#{options[:base_url]}/_search/scroll"
                dsl = { scroll: scroll_timer, scroll_id: scroll_id }
                puts dsl.to_json
                response = SearchResultSet.new(RestClient.post(url, dsl.to_json, {}))
            end
            def self.create_index options
                url = "#{options[:base_url]}/#{options[:index]}"
                response = JSON.parse(RestClient.put(url, {}.to_json, {})).to_hash
            end
            def self.destroy_index options
                url = "#{options[:base_url]}/#{options[:index]}"
                response = JSON.parse(RestClient.delete(url)).to_hash
            end
            def self.create_mapping options
                url = "#{options[:base_url]}/#{options[:index]}/_mappings/#{options[:type]}"
                response = JSON.parse(RestClient.put(url, options[:map].to_json, {})).to_hash
            end
        end
        class SearchResultSet
            attr_accessor :scroll_id, :took, :timed_out, :shards_total, :shards_successful, :shards_failed, :hits_total, :hits_maxscore, :hits
            def initialize elasticsearch_search_result
                esr = JSON.parse(elasticsearch_search_result)
                self.scroll_id = esr["_scroll_id"]
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
                self.index = elasticsearch_search_result_hit["_index"]
                self.type = elasticsearch_search_result_hit["_type"]
                self.id = elasticsearch_search_result_hit["_id"]
                self.source = elasticsearch_search_result_hit["_source"]
            end
        end
    end
end