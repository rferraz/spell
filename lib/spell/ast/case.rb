module Ast

  class Case

    def initialize(items)
      @items = items
    end

    def to_sexp
      [:case] + @items.collect(&:to_sexp)
    end

  end

  class CaseItem

    def initialize(condition, result)
      @condition, @result = condition, result
    end

    def to_sexp
      [@condition.to_sexp, @result.to_sexp]
    end

  end

  class DefaultCaseItem

    def to_sexp
      []
    end

  end

end
