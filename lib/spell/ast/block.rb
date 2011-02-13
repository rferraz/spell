module Ast

  class Block

    attr_reader :arguments
    attr_reader :expressions

    def initialize(arguments, expressions)
      @arguments, @expressions = arguments, expressions
    end

    def to_sexp
      [:block] +
        (@arguments.empty? ? [] : [[:arguments] + @arguments]) +
        @expressions.collect(&:to_sexp)
    end

  end

end
