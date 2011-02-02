module Ast

  class Primitive

    def initialize(name)
      @name = name
    end

    def to_sexp
      [:primitive, @name]
    end

  end

end
