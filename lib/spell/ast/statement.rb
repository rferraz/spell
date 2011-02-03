module Ast

  class Statement

    attr_reader :body

    def initialize(name, arguments, bindings, body)
      @name, @arguments, @bindings, @body = name, arguments, bindings, body
    end

    def to_sexp
      [:define, @name] +
        (@arguments.empty? ? [] : [[:arguments] + @arguments]) +
        (@bindings.empty? ? [] : [[:bindings] + @bindings.collect(&:to_sexp)]) +
        @body.collect(&:to_sexp)
    end

  end

end
