module Statement

  def build
    Ast::Statement.new(identifier.text_value.to_sym,
                       body.expressions.build)
  end

end
