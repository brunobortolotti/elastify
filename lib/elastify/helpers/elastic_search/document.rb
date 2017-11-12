module Elastify
    module Helpers
        module ElasticSearch
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
        end
    end
end