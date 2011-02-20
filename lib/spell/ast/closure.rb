module Ast

  class Closure

    attr_reader :arguments_size
    attr_reader :literal_frame
    attr_reader :body

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
