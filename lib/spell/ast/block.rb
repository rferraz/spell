module Ast

  class Block

    attr_reader :arguments
    attr_reader :body

    def initialize(arguments, body)
      @arguments, @body = arguments, body
    end

    def to_sexp
      [:block] +
        (@arguments.empty? ? [] : [[:arguments] + @arguments]) +
        @body.collect(&:to_sexp)
    end

  end

end
