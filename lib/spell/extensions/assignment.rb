module Assignment

  def build
    Ast::Assignment.new(identifier.text_value, expression.build)
  end

end
