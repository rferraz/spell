module Primary

  def build
    if respond_to?(:dictionary)
      dictionary.elements.inject(value.build) { |memo, element|
        Ast::DictionaryAccess.new(memo, element.identifier.text_value)
      }
    else
      value.build
    end
  end

end
