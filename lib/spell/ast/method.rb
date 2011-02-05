module Ast

  class Method

    def initialize(name, literal_frame, body)
      @name, @literal_frame, @body = name, literal_frame, body
    end

    def to_sexp
      [:method, @name] +
        ([[:activation] + (@literal_frame.empty? ? [[]] : @literal_frame.collect { |literal| [:const, literal] })]) +
        @body.collect(&:to_sexp)
    end

  end

end
