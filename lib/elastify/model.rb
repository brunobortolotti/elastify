module Elastify
    class Model
        attr_accessor :opt_index, :opt_type, :opt_mapping, :opt_encode, :opt_decode, :opt_scroll_timeout

        def index(index)
            @opt_index = index
        end

        def type(type)
            @opt_type = type
        end

        def mapping(&block)
            @opt_mapping = block.call() if block_given?
        end

        def mapping_file(file_name)
            file_path = file_name.instance_of?(Pathname) ? file_name : Rails.root.join('config', 'elastify', 'mappings', file_name)
            @opt_mapping = JSON.parse(File.read(file_path)).deep_symbolize_keys if File.exist?(file_path)
        end

        def encode(&block)
            @opt_encode = block if block_given?
        end

        def decode(&block)
            @opt_decode = block if block_given?
        end

        def scroll_timeout(scroll_timeout)
            @opt_scroll_timeout = scroll_timeout
        end
    end
end