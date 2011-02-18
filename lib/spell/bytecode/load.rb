module Bytecode

  class Load
    
    attr_reader :type
    attr_reader :index
    
    def initialize(type, index)
      @type, @index = type, index
    end
    
    def inspect
      "load #{@type} #{@index}"
    end
    
  end
  
end