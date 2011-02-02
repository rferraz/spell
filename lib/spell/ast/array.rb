module Ast

  class Array

    def initialize(items)
      @items = items
    end

    def to_sexp
      [:array, :new, @items.collect(&:to_sexp)]
    end

  end

  class ArrayItem

    def initialize(expression)
      @expression = expression
    end

    def to_sexp
      @expression.to_sexp
    end

  end

  class ArrayAccess

    def initialize(target, accessor)
      @target, @accessor = target, accessor
    end

    def to_sexp
      [:dictionary, :access, @target.to_sexp, @accessor]
    end

  end

end
