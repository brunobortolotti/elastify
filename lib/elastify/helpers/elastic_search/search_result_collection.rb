module Elastify
    module Helpers
        module ElasticSearch
            class SearchResultCollection
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
        end
    end
end