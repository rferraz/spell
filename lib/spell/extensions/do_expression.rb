module DoLines

  def build
    elements.collect { |element| element.expression.build }
  end

end

module DoBlock

  def build
    [head.build] + rest.elements.collect { |element| element.expression.build }
  end

end
