require "elastify/version"
require "elastify/active_record_extensions"

module Elastify
    cattr_accessor :defaults
    

    class << self
        
    end

    class ElastifyError < StandardError; end
end
