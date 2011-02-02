module Block

  def build
    Ast::Block.new(argument_list, expressions)
  end

  private

  def argument_list
    if list && list.respond_to?(:head)
      [list.head.text_value] + list.rest.elements.collect { |element| element.identifier.text_value }
    else
      []
    end
  end

  def expressions
    [body.head.build] + body.rest.elements.collect { |element| element.expression.build }
  end

end
