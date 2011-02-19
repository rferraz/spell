module Bytecode

  class JumpFalse

    attr_reader :offset

    def initialize(offset)
      @offset = offset
    end

    def inspect
      "jump false #{@offset}"
    end

  end

end
