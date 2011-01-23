module Ast

  class Literal

    def initialize(value)
      @value = value
    end

    def to_sexp
      [:literal, @value]
    end

  end

end
