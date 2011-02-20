module Block

  def build
    Ast::Block.new(argument_list, [body.build].flatten)
  end

  private

  def argument_list
    if list && list.respond_to?(:head)
      [list.head.text_value] + list.rest.elements.collect { |element| element.identifier.text_value }
    else
      []
    end
  end

end

module BlockExpression

  def build
    [head.build] + rest.elements.collect { |element| element.expression.build }
  end

end
