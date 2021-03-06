module Ast

  class Expression

    attr_reader :body

    def initialize(body)
      @body = body
    end

    def to_sexp
      @body.to_sexp
    end

  end

end
