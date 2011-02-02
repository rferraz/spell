module Primary

  def build
    if access && access.elements
      access.elements.inject(value.build) { |memo, element|
        if element.respond_to?(:identifier)
          Ast::DictionaryAccess.new(memo, element.identifier.text_value)
        else
          Ast::ArrayAccess.new(memo, element.index.text_value.to_i)
        end
      }
    else
      value.build
    end
  end

end
