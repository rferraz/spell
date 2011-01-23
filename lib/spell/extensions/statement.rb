module Statement

  def build
    argument_list = if arguments && arguments.list.respond_to?(:head)
                  [arguments.list.head.text_value] + arguments.list.rest.elements.collect { |element| element.identifier.text_value }
                else
                  []
                end
    Ast::Statement.new(identifier.text_value,
                       argument_list,
                       body.expressions.build)
  end

end
