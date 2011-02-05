module Ast

  class Literal

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_sexp
      [:literal, @value]
    end

  end

end
