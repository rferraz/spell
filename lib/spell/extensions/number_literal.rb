module NumberLiteral

  def build
    if respond_to?(:period)
      Ast::Literal.new(text_value.to_f)
    else
      Ast::Literal.new(text_value.to_i)
    end
  end

end
