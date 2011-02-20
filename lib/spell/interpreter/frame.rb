class Frame

  attr_reader :return_ip
  attr_reader :previous

  def initialize(return_ip, previous = nil, value_offset = 0, arguments = [], context_frame = nil)
    @return_ip = return_ip
    @value_offset = value_offset
    @previous = previous
    @context_frame = context_frame
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

  def up(index, distance)
    context = @context_frame
    (distance - 1).times { context = @context_frame.previous }
    @stack.push(context.get_up_value(index))
  end
  
  def arguments(count)
    @stack.slice!(-count, count)
  end
  
  def closure_arguments
    index = @stack.rindex { |item| item.is_a?(ClosureContext) }
    arguments(@stack.size - index)
  end

  def inspect
    "@#{@return_ip} -> #{@stack.inspect}"
  end

  protected

  def get_up_value(index)
    @stack[index]
  end

end
