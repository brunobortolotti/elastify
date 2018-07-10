module Elastify
    class Config

        attr_accessor :connection

        def initialize
            @connection = OpenStruct.new({protocol: 'http', host: 'localhost', port: '9200'})
        end

        def base_url=(uri)
            m1 = /(http|https)\:\/\/([A-z0-9\_\-\.]+)\:([0-9]+)/.match(uri)
            raise ArgumentError, 'Invalid URI' unless m1.present?
            @connection.protocol = m1[1]
            @connection.host = m1[2]
            @connection.port = m1[3]
        end

        def base_url
            "#{@connection.protocol}://#{@connection.host}:#{@connection.port}"
        end


        # OpenStruct.new({
        #     connection: ,
        #     indices: OpenStruct.new({default: ''}),
        #     mappings: OpenStruct.new({autoload: true, autoload_path: Rails.root.join('config/elastify/mappings')}),
        # })

    end
end