module Ast

  class Assignment

    attr_reader :name
    attr_reader :expression

    def initialize(name, expression)
      @name, @expression = name, expression
    end

    def to_sexp
      [@name, @expression.to_sexp]
    end

  end

end
