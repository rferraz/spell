module Dictionary

  def build
    Ast::Dictionary.new(dictionary_items)
  end

  private

  def dictionary_items
    if list && list.respond_to?(:head)
      [Ast::DictionaryItem.new(list.head.identifier.text_value,
                               list.head.expression.build)] +
        list.rest.elements.collect { |element|
          Ast::DictionaryItem.new(element.item.identifier.text_value,
                                  element.item.expression.build)
        }
    else
      []
    end
  end

end
