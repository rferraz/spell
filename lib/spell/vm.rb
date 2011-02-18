class VM

  def initialize(instructions)
    # puts instructions.inspect
    @instructions = instructions
  end

  def run
    reset_ip
    while has_instructions?
      execute(current_instruction)
      next_instruction
    end
    stack.pop
  end

  protected

  def stack
    @stack ||= []
  end

  def ip
    @ip
  end

  def reset_ip
    @ip = 0
  end

  def has_instructions?
    @ip < @instructions.size
  end

  def next_instruction
    @ip += 1
  end

  def current_instruction
    @instructions[@ip]
  end

  def execute(instruction)
    operator, *arguments = instruction
    case operator
    when :invoke
    end
  end

end
