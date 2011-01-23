module Ast

  class Invoke

    def initialize(message, arguments)
      @message, @arguments = message, arguments
    end

    def to_sexp
      [:invoke, @message] + @arguments.collect(&:to_sexp)
    end

  end

end
