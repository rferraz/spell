module Bytecode

  class Push

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def inspect
      "push #{@value || :nothing}"
    end

  end

end