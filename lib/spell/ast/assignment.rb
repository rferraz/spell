module Ast

  class Assignment

    def initialize(binding, expression)
      @binding, @expression = binding, expression
    end

    def to_sexp
      [@binding, @expression.to_sexp]
    end

  end

end
