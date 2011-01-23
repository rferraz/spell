module WithLines

  def build
    elements.collect { |element| Ast::Expression.new(element.binding.build) }
  end

end

module WithBlock

  def build
    [head.build] + rest.elements.collect { |element| element.expression.build }
  end

end
