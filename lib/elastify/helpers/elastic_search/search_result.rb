module Elastify
    module Helpers
        module ElasticSearch
            class SearchResult
                attr_accessor :index, :type, :id, :score, :source,
                              :elastify_options

                def initialize(elasticsearch_search_result_hit, elastify_options)
                    @index = elasticsearch_search_result_hit["_index"]
                    @type = elasticsearch_search_result_hit["_type"]
                    @id = elasticsearch_search_result_hit["_id"]
                    @source = elasticsearch_search_result_hit["_source"]
                    @elastify_options = elastify_options
                end

                def decode
                    data = {}
                    if @elastify_options[:decode]
                        data = @elastify_options[:decode].call(@source)
                    end
                    return data
                end
            end
        end
    end
end