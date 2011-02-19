module Bytecode

  class Store
    
    attr_reader :type
    attr_reader :index
    
    def initialize(type, index)
      @type, @index = type, index
    end
    
    def inspect
      "store #{@type} #{@index}"
    end
    
  end
  
end