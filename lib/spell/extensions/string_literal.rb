module StringLiteral

  def build
    Ast::Literal.new(text_value.gsub("\\\"", "\""))
  end

end
