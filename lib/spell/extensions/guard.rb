module Guard

  def build
    Ast::Case.new(case_items)
  end

  private

  def case_items
    elements.collect { |element|
      Ast::CaseItem.new(Ast::Expression.new(element.guard.condition.build),
                        Ast::Expression.new(element.guard.result.build))
    }
  end

end

module DefaultGuard

  def build
    Ast::DefaultCaseItem.new
  end

end
