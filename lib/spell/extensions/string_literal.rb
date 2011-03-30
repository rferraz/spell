module StringLiteral

  def build
    value = text_value.gsub(/(\\.)/) { |m| eval("\"" + m + "\"") }
    Ast::Literal.new(value)
  end

end
