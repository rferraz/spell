module Bytecode

  class Invoke
    
    include Storable
    
    attr_reader :method
    
    def initialize(method)
      @method = method
    end
    
    def inspect
      "invoke #{@method}"
    end
    
  end
  
end