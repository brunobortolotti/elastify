module Elastify
    module Helpers
        module ElasticSearch
            class Document
                cattr_accessor :options
                def initialize(options = {})
                    @options = options
                end
                def create(model)
                    Connector.create(@options, model)
                end
                def update(model)
                    Connector.update(@options, model)
                end
                def destroy(model)
                    Connector.destroy(@options, model)
                end
                def search(dsl, scroll_timeout = nil)
                    Connector.search(@options, dsl, scroll_timeout)
                end
                def scroll(scroll_id, scroll_timeout = nil)
                    Connector.scroll(@options, scroll_id, scroll_timeout)
                end
            end
        end
    end
end