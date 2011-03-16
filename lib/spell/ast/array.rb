module Ast

  class ArrayLiteral

    attr_reader :items

    def initialize(items)
      @items = items
    end

    def to_sexp
      [:array, :new, @items.collect(&:to_sexp)]
    end

  end

  class ArrayItem

    attr_reader :expression

    def initialize(expression)
      @expression = expression
    end

    def to_sexp
      @expression.to_sexp
    end

  end

  class ArrayAccess

    attr_reader :target
    attr_reader :index

    def initialize(target, index)
      @target, @index = target, index
    end

    def to_sexp
      [:array, :access, @target.to_sexp, @index.to_sexp]
    end

  end

end
