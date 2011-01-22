module Ast

  class Statement

    def initialize(name, body)
      @name = name
      @body = body
    end

    def to_sexp
      [@name, @body.to_sexp]
    end

  end

end
