module Call

  def build
    Ast::Invoke.new(identifier.text_value,
                    parameters.elements.collect { |element|
                      if element.parameter.respond_to?(:identifier)
                        Ast::Invoke.new(element.parameter.text_value, [])
                      else
                        element.parameter.build
                      end
                    })
  end

end
