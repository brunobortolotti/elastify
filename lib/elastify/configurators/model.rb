module Elastify
    module Configurators
        class Model

            attr_accessor :map_index, :map_type, :map_mapping, :map_encode, :map_decode

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
