module Primitive

  def build
    Ast::Primitive.new(identifier.text_value)
  end

end
