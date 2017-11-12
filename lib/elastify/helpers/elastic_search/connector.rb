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
                    puts options[:map]
                    response = JSON.parse(RestClient.put(url, options[:map].squish, {})).to_hash
                end
            end
        end
    end
end
