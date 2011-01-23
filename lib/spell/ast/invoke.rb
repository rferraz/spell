module Ast

  class Invoke

    def initialize(message, parameters)
      @message, @parameters = message, parameters
    end

    def to_sexp
      [:invoke, @message] + @parameters.collect(&:to_sexp)
    end

  end

end
