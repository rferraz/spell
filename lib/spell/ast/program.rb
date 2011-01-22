module Ast

  class Program

    def initialize(statements)
      @statements = statements
    end

    def to_sexp
      @statements.collect(&:to_sexp)
    end

  end

end
