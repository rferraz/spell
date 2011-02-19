module Ast

  class Case

    attr_reader :items

    def initialize(items)
      @items = items
    end

    def to_sexp
      [:case] + @items.collect(&:to_sexp)
    end

  end

  class CaseItem

    attr_reader :condition
    attr_reader :result

    def initialize(condition, result)
      @condition, @result = condition, result
    end

    def to_sexp
      [@condition.to_sexp, @result.to_sexp]
    end

  end

  class NullCaseCondition

    def to_sexp
      []
    end

  end

end
