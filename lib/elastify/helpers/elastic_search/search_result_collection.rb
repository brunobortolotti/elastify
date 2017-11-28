module Elastify
    module Helpers
        module ElasticSearch
            class SearchResultCollection
                attr_accessor :scroll_id, :took, :timed_out, :shards_total, :shards_successful, :shards_failed, :hits_total, :hits_maxscore, :hits,
                              :elastify_options

                def initialize(elasticsearch_search_result, elastify_options)
                    esr = JSON.parse(elasticsearch_search_result)
                    @scroll_id = esr["_scroll_id"]
                    @took = esr["took"]
                    @timed_out = esr["timed_out"]
                    @shards_total = esr["_shards"]["total"]
                    @shards_successful = esr["_shards"]["successful"]
                    @shards_failed = esr["_shards"]["failed"]
                    @hits_total = esr["hits"]["total"]
                    @hits_maxscore = esr["hits"]["maxscore"]
                    @hits = esr["hits"]["hits"].map{ |hit| Elastify::Helpers::ElasticSearch::SearchResult.new(hit, elastify_options) }
                    @elastify_options = elastify_options
                end
            end
        end
    end
end