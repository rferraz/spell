module Ast

  class DictionaryLiteral

    attr_reader :items

    def initialize(items)
      @items = items
    end

    def to_sexp
      [:dictionary, :new, @items.collect(&:to_sexp)]
    end

  end

  class DictionaryItem

    attr_reader :name
    attr_reader :expression

    def initialize(name, expression)
      @name, @expression = name, expression
    end

    def to_sexp
      [@name, @expression.to_sexp]
    end

  end

  class DictionaryAccess

    attr_reader :target
    attr_reader :accessor

    def initialize(target, accessor)
      @target, @accessor = target, accessor
    end

    def to_sexp
      [:dictionary, :access, @target.to_sexp, @accessor]
    end

  end

end
