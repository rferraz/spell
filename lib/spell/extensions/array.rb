module ArrayLiteral

  def build
    Ast::ArrayLiteral.new(array_items)
  end

  private

  def array_items
    if list && list.respond_to?(:head)
      [Ast::ArrayItem.new(list.head.build)] +
        list.rest.elements.collect { |element| 
          Ast::ArrayItem.new(element.expression.build) 
        }
    else
      []
    end
  end

end
