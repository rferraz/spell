module Binary

  def build
    Ast::Invoke.new(selector.text_value, [operand1.build, operand2.build])
  end

end
