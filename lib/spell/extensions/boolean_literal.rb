module BooleanLiteral

  def build
    Ast::Literal.new(text_value == "true" ? 1 : 0)
  end

end
