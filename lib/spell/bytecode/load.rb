module Bytecode

  class Load
    
    include Storable
    
    attr_reader :type
    attr_reader :index
    
    def initialize(type, index)
      @type, @index = type, index
    end
    
    def inspect
      "load #{@type} #{@index}"
    end
    
    def self.load(type, index)
      new(type.to_sym, index.to_i)
    end
    
  end
  
end