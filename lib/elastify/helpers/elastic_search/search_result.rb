module Elastify
    module Helpers
        module ElasticSearch
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
end