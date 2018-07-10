module Elastify
    module Helpers
        module ElasticSearch
            class Connector

                def self.create(options, data)
                    if data.blank?
                        raise :elastify__create__required_data
                    end
                    if data[:id].blank?
                        raise :elastify__create__required_data_id
                    end
                    url = "#{options[:base_url]}/#{options[:index]}/#{options[:type]}/#{data[:id]}"
                    JSON.parse(RestClient.put(url, data.to_json, {}))
                end

                def self.update(options, data)
                    if data.blank?
                        raise :elastify__update__required_data
                    end
                    if data[:id].blank?
                        raise :elastify__update__required_data_id
                    end
                    url = "#{options[:base_url]}/#{options[:index]}/#{options[:type]}/#{data[:id]}"
                    JSON.parse(RestClient.put(url, data.to_json, {})).to_hash
                end

                def self.destroy(options, data)
                    if data.blank?
                        raise :elastify__delete__required_data
                    end
                    if data[:id].blank?
                        raise :elastify__delete__required_data_id
                    end
                    url = "#{options[:base_url]}/#{options[:index]}/#{options[:type]}/#{data[:id]}"
                    JSON.parse(RestClient.delete(url)).to_hash
                end

                def self.search(options, dsl, scroll_timeout)
                    if dsl.blank?
                        raise :elastify__search__required_dsl
                    end
                    url = "#{options[:base_url]}/#{options[:index]}/#{options[:type]}/_search"
                    scroll_timeout ||= options[:scroll_timeout]
                    url += "?scroll=#{scroll_timeout}" if scroll_timeout.present?
                    Elastify::Helpers::ElasticSearch::SearchResultCollection.new(RestClient.post(url, dsl.to_json, {}), options)
                end

                def self.scroll(options, scroll_id, scroll_timeout)
                    if scroll_id.blank?
                        raise :elastify__search__required_scroll_id
                    end
                    url = "#{options[:base_url]}/_search/scroll"
                    dsl = { scroll_id: scroll_id }
                    scroll_timeout ||= options[:scroll_timeout]
                    dsl[:scroll] = scroll_timeout if scroll_timeout.present?
                    Elastify::Helpers::ElasticSearch::SearchResultCollection.new(RestClient.post(url, dsl.to_json, {}), options)
                end

                def self.create_index(options)
                    url = "#{options[:base_url]}/#{options[:index]}"
                    JSON.parse(RestClient.put(url, {}.to_json, {})).to_hash
                end

                def self.destroy_index(options)
                    url = "#{options[:base_url]}/#{options[:index]}"
                    JSON.parse(RestClient.delete(url)).to_hash
                end

                def self.create_mapping(options)
                    url = "#{options[:base_url]}/#{options[:index]}/_mappings/#{options[:type]}"
                    JSON.parse(RestClient.put(url, options[:map].squish, {})).to_hash
                end
            end
        end
    end
end
