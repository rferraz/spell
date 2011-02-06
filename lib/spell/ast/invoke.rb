module Ast

  class Invoke

    attr_reader :message
    attr_reader :parameters

    def initialize(message, parameters, resolved = true)
      @message, @parameters, @resolved = message, parameters, resolved
    end

    def to_sexp
      [@resolved ? :invoke : :unresolved, @message] + @parameters.collect(&:to_sexp)
    end

    def resolve!
      @resolved = true
    end

  end

end
