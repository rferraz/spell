module Program

  def build
    Ast::Program.new([root.head.build] + root.rest.elements.collect { |element| element.statement.build })
  end

end
