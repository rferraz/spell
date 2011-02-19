module Guard

  def build
    Ast::Case.new(case_items)
  end

  private

  def case_items
    elements.collect { |element|
      Ast::CaseItem.new(element.guard.condition.build,
                        element.guard.result.build)
    }
  end

end

module DefaultGuard

  def build
    Ast::NullCaseCondition.new
  end

end
