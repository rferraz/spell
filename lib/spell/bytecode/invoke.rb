module Bytecode

  class Invoke
    
    attr_reader :method
    
    def initialize(method)
      @method = method
    end
    
    def inspect
      "invoke #{@method}"
    end
    
  end
  
end