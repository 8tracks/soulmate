module Soulmate
  
  class Base
    
    include Helpers
    
    attr_accessor :type
    
    def initialize(type)
      @type = normalize(type)
    end
    
    def base
      "sm:i:#{type}"
    end

    def database
      "sm:d:#{type}"
    end

    def cachebase
      "sm:c:#{type}"
    end
  end
end