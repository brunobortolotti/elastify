module Elastify
    module Helpers
        class QueryBuilder

            attr_accessor :queries, :filters, :sort, :scroll_size, :scroll_timeout

            def initialize(scroll_size: 15, scroll_timeout: '1m')
                @queries = []
                @filters = []
                @sort = {}
                @scroll_size = scroll_size
                @scroll_timeout = scroll_timeout
            end

            def search_term(fields, term)
                @queries << { term: term, fields: fields.instance_of?(Array) ? fields : [fields] }
            end

            def filter(*args)
                must_filter(*args)
            end

            def must_filter(fields, field_rules)
                @filters << { type: :must, field_rules: field_rules, fields: fields.instance_of?(Array) ? fields : [fields] }
            end

            def should_filter(fields, field_rules)
                @filters << { type: :should, field_rules: field_rules, fields: fields.instance_of?(Array) ? fields : [fields] }
            end

            def sort(field, direction)
                @sort[field] = { order: direction }
            end

            def scroll(scroll_size, scroll_timeout)
                @scroll_size = scroll_size
                @scroll_timeout = scroll_timeout
            end

            def scroll_size(size)
                @scroll_size = size
            end

            def scroll_timeout(timeout)
                @scroll_timeout = timeout
            end

            def to_dsl
                max_scroll_size = 100; @scroll_size ||= 15
                @scroll_size = @scroll_size.to_i <= max_scroll_size ? @scroll_size : max_scroll_size
                if @sort.blank?
                    @sort = @queries.blank? ? { id: { order: :desc } } : { _score: { order: :desc } }
                end
                dsl = { sort: @sort, size: @scroll_size, query: {} }
                if @queries.blank? and @filters.blank?
                    dsl[:query][:match_all] = {}
                    return dsl
                end
                dsl[:query] = { bool: { must: [], must_not: [], should: [] } }
                if @queries.present?
                    dsl[:query][:bool][:must] += @queries.map do |query|
                        { multi_match: { query: "#{query[:term].sanitize}", fields: query[:fields], operator: :and } }
                    end
                end
                if @filters.present?
                    @filters.select { |filter| filter[:type].equal?(:must) }.each do |filter|
                        filter[:fields].each do |field|
                            dsl[:query][:bool][:must] += map_has(field, filter[:field_rules][:has]) if filter[:field_rules][:has].present?
                            dsl[:query][:bool][:must] << map_in(field, filter[:field_rules][:in]) if filter[:field_rules][:in].present?
                            dsl[:query][:bool][:must_not] << map_in(field, filter[:field_rules][:not_in]) if filter[:field_rules][:not_in].present?
                            dsl[:query][:bool][:must] << map_range(field, filter[:field_rules][:range]) if filter[:field_rules][:range].present?
                        end
                    end
                    @filters.select { |filter| filter[:type].equal?(:should) }.each do |filter|
                        filter[:fields].each_with_index do |field, index|
                            dsl[:query][:bool][:should][index] ||= { bool: { must: [], must_not: [] } }
                            dsl[:query][:bool][:should][index][:bool][:must] += map_has(field, filter[:field_rules][:has]) if filter[:field_rules][:has].present?
                            dsl[:query][:bool][:should][index][:bool][:must] << map_in(field, filter[:field_rules][:in]) if filter[:field_rules][:in].present?
                            dsl[:query][:bool][:should][index][:bool][:must_not] << map_in(field, filter[:field_rules][:not_in]) if filter[:field_rules][:not_in].present?
                            dsl[:query][:bool][:should][index][:bool][:must] << map_range(field, filter[:field_rules][:range]) if filter[:field_rules][:range].present?
                        end
                    end
                    dsl[:query][:bool][:minimum_number_should_match] = 1 if dsl[:query][:bool][:should].present?
                end
                return dsl
            end

            private
            def map_has(field, data)
                data.map { |value| { term: { field.to_s => value } } }
            end

            def map_in(field, data)
                { terms: { field.to_s => data } }
            end

            def map_not_in(field, data)
                { terms: { field.to_s => data } }
            end

            def map_range(field, data)
                { range: { field.to_s => { gte: data.first, lte: data.last, format: 'yyyy-MM-dd\'T\'HH:mm:ssZ' } } }
            end
        end
    end
end