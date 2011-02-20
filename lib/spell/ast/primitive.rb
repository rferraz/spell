module Ast

  class Primitive

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def to_sexp
      [:primitive, @name]
    end

  end

end
