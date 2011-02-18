class VM

  def initialize(instructions, primitives = [])
    @primitives = primitives
    @instructions = instructions
  end

  def run
    reset_ip
    reset_sp
    reset_call_sites
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

  def reset_sp
    @sp = @ip
  end
  
  def reset_ip
    @ip = @instructions.size - 1
  end
  
  def reset_call_sites
    @call_sites = []
  end
  
  def enter_call_site(sp)
    @call_sites.push(:sp => sp)
  end
  
  def leave_call_site
    @call_sites.pop
  end

  def sp
    @call_sites.last[:sp]
  end
  
  def ip_of(instruction)
    @instructions.index(instruction)
  end
  
  def jump_to(new_ip)
    @ip = new_ip
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
    case instruction
    when Bytecode::Invoke
      call_method(instruction.method)
    when Bytecode::Push
      stack.push(instruction.value)
    when Bytecode::Load
      stack.push(stack[sp + instruction.index])
    when Bytecode::Return
      return_from_method
    else
      raise SpellInvalidBytecodeError.new("Invalid bytecode: #{instruction.inspect}")
    end
  end
  
  def call_method(name)
    instruction = @instructions.find { |instruction| instruction.is_a?(Bytecode::Label) && instruction.name == name }
    if instruction
      stack.push(ip)
      enter_call_site(stack.size)
      jump_to(ip_of(instruction))
    else
      primitive = primitive_for(name)
      if primitive
        stack.push(primitive.call(*arguments(primitive.arity)))
      else
        raise SpellInvalidMethodCallError.new("Invalid method \"#{name}\" called")
      end
    end
  end
  
  def return_from_method
    return_value = stack.pop
    stack.slice!(sp, stack.size - sp)
    leave_call_site
    jump_to(stack.pop)
    stack.push(return_value)
  end
  
  def primitive_for(name)
    @primitives[name]
  end
  
  def arguments(count)
    parameters = []
    count.times { parameters.push(stack.pop) }
    parameters
  end

end
