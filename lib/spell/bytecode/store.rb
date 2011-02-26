module Bytecode

  class Store
    
    include Storable
    
    attr_reader :type
    attr_reader :index
    
    def initialize(type, index)
      @type, @index = type, index
    end
    
    def inspect
      "store #{@type} #{@index}"
    end
    
    def self.load(type, index)
       new(type.to_sym, index.to_i)
     end
    
  end
  
end