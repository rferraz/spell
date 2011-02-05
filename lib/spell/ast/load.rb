module Ast

  class Load

    def initialize(type, index)
      @type, @index = type, index
    end

    def to_sexp
      [:load, @type, @index]
    end

  end

end
