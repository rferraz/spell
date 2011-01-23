module Statement

  def build
    Ast::Statement.new(identifier.text_value,
                       body.expressions.build)
  end

end
