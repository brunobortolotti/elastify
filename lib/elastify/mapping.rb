module Elastify
    module Mapping

        class << self
            def register(model_class, &block)
                map = MapObject.new(model_class)
                if block_given?
                    yield(map)
                end
                model_class.send(:include, Elastify::Model)
                model_class.elastify_mapping = map
            end
        end

        class MapObject

            attr_accessor :map_model_class, :map_index, :map_type, :map_mapping, :map_encode, :map_decode

            def initialize(model_class)
                @map_model_class = model_class
            end

            def index(index)
                @map_index = index
            end

            def type(type)
                @map_type = type
            end

            def mapping(&block)
                @map_mapping = block.call() if block_given?
            end

            def encode(&block)
                @map_encode = block if block_given?
            end

            def decode(&block)
                @map_decode = block if block_given?
            end
        end
    end

end