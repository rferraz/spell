module Bytecode

  class JumpFalse
    
    include Storable

    attr_reader :offset

    def initialize(offset)
      @offset = offset
    end

    def inspect
      "jump false #{@offset}"
    end
    
    def self.load(offset)
      new(offset.to_i)
    end

  end

end
