
module Statement

  def build
    Ast::Statement.new(identifier.text_value, argument_list, bindings, expressions)
  end

  private

  def argument_list
    if arguments && arguments.list.respond_to?(:head)
      [arguments.list.head.text_value] +
        arguments.list.rest.elements.collect { |element| element.identifier.text_value }
    else
      []
    end
  end

  def expressions
    if body.expressions.respond_to?(:build)
      [Ast::Expression.new(body.expressions.build)]
    elsif
      block = expose_block(body.expressions)
      block.elements.inject([]) { |memo, element|
        memo += element.build if element.respond_to?(:build)
        memo
      }
    end
  end

  def bindings
    if body.with && body.with.respond_to?(:with_expression)
      block = expose_block(body.with.with_expression)
      block.elements.inject([]) { |memo, element|
        memo += element.build if element.respond_to?(:build)
        memo
      }
    else
      []
    end
  end

  def expose_block(node)
    node.elements.find { |element| element.respond_to?(:body) } ||
      node
  end

end
