module Ast

  class Method

    attr_reader :name
    attr_reader :arguments_size
    attr_reader :bindings_size
    attr_reader :literal_frame
    attr_reader :body

    def initialize(name, arguments_size, bindings_size, literal_frame, body)
      @name, @arguments_size, @bindings_size, @literal_frame, @body = name, arguments_size, bindings_size, literal_frame, body
    end

    def to_sexp
      [:method, @name] +
        ([[:activation] +
          (@arguments_size.zero? ? [] : [[:arguments, @arguments_size]]) +
          (@bindings_size.zero? ? [] : [[:bindings, @bindings_size]]) +
          (@literal_frame.empty? ? [[]] : @literal_frame.collect { |literal| [:const, literal] })]) +
        @body.collect(&:to_sexp)
    end

  end

end
