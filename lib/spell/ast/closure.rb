module Ast

  class Closure

    def initialize(arguments_size, literal_frame, body)
      @arguments_size, @literal_frame, @body = arguments_size, literal_frame, body
    end

    def to_sexp
      [:closure] +
        ([[:activation] +
          (@arguments_size.zero? ? [] : [[:arguments, @arguments_size]]) +
          (@literal_frame.empty? ? [[]] : @literal_frame.collect { |literal| [:const, literal] })]) +
        @body.collect(&:to_sexp)
    end

  end

end
