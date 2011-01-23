module Call

  def build
    Ast::Invoke.new(identifier.text_value, [])
  end

end
