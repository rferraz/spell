module Bytecode

  class Invoke
    
    attr_reader :message
    
    def initialize(message)
      @message = message
    end
    
    def inspect
      "invoke #{@message}"
    end
    
  end
  
end