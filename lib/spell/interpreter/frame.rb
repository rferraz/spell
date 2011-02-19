class Frame

  attr_reader :return_ip

  def initialize(return_ip, value_offset = 0, arguments = [])
    @return_ip, @value_offset = return_ip, value_offset
    @stack = arguments
  end

  def push(value)
    @stack.push(value)
  end

  def pop
    @stack.pop
  end

  def load_const(index)
    @stack.push(@stack[index + @value_offset])
  end

  def load_value(index)
    @stack.push(@stack[index])
  end

  def store_value(index)
    @stack[index] = @stack.pop
  end

  def inspect
    "@#{@return_ip} -> #{@stack.inspect}"
  end

end
