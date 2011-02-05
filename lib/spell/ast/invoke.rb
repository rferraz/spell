module Ast

  class Invoke

    attr_reader :message
    attr_reader :parameters

    def initialize(message, parameters)
      @message, @parameters = message, parameters
    end

    def to_sexp
      [:invoke, @message] + @parameters.collect(&:to_sexp)
    end

  end

  class UnresolvedInvoke < Invoke; end

end
