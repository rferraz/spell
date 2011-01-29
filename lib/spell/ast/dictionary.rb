module Ast

  class Dictionary

    def initialize(items)
      @items = items
    end

    def to_sexp
      [:dictionary, :new, @items.collect(&:to_sexp)]
    end

  end

  class DictionaryItem

    def initialize(name, expression)
      @name, @expression = name, expression
    end

    def to_sexp
      [@name, @expression.to_sexp]
    end

  end

end
