module Elastify
    module Configurators
        class Model

            attr_accessor :opt_index, :opt_type, :opt_mapping, :opt_encode, :opt_decode

            def index(index)
                @opt_index = index
            end

            def type(type)
                @opt_type = type
            end

            def mapping(&block)
                @opt_mapping = block.call() if block_given?
            end

            def encode(&block)
                @opt_encode = block if block_given?
            end

            def decode(&block)
                @opt_decode = block if block_given?
            end
        end
    end
end
