class VM

  BINARY_PRIMITIVES = %w(+ - * / ** & | < > <= >= ==)

  BLOCK_PRIMITIVES = %w(apply)

  PRIMITIVES = BINARY_PRIMITIVES + BLOCK_PRIMITIVES

  def initialize(instructions, primitives = [], debug = false)
    @debug = debug
    @primitives = primitives
    @instructions = instructions
  end

  def run
    if debug?
      puts @instructions.collect { |instruction| instruction.inspect }
    end
    reset_ip
    reset_frames
    while has_instructions?
      execute(current_instruction)
      next_instruction
    end
    current_frame.pop
  end

  protected

  def debug?
    @debug
  end

  def ip
    @ip
  end

  def reset_ip
    @ip = @instructions.size - 1
  end

  def reset_frames
    @current_frame = Frame.new(ip)
  end

  def enter(value_offset, arguments)
    @current_frame = Frame.new(ip, @current_frame, value_offset, arguments)
  end

  def leave
    @current_frame = @current_frame.previous
  end

  def enter_closure(context, arguments)
    @current_frame = Frame.new(ip, @current_frame, arguments.size, arguments, context.frame)
  end

  def leave_closure
    @current_frame = @current_frame.previous
  end

  def current_frame
    @current_frame
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
    if debug?
      puts "frame before: " + current_frame.inspect
      puts instruction.inspect
    end
    case instruction
    when Bytecode::Invoke
      invoke_method(instruction.method)
    when Bytecode::Return
      return_from_method
    when Bytecode::Push
      current_frame.push(instruction.value)
    when Bytecode::JumpFalse
      jump_to(ip + instruction.offset) unless current_frame.pop
    when Bytecode::Load
      if instruction.type == :const
        current_frame.load_const(instruction.index)
      else
        current_frame.load_value(instruction.index)
      end
    when Bytecode::Store
      current_frame.store_value(instruction.index)
    when Bytecode::Dictionary
      current_frame.push(Hash.new)
    when Bytecode::DictionaryGet
      current_frame.push(current_frame.pop[instruction.name])
    when Bytecode::DictionarySet
      value, hash = current_frame.pop, current_frame.pop
      hash[instruction.name] = value
      current_frame.push(hash)
    when Bytecode::Array
      current_frame.push(Array.new)
    when Bytecode::ArrayGet
      current_frame.push(current_frame.pop[current_frame.pop])
    when Bytecode::ArraySet
      value, array = current_frame.pop, current_frame.pop
      array.push(value)
      current_frame.push(array)
    when Bytecode::DictionaryGet
      current_frame.push(current_frame.pop[instruction.name])
    when Bytecode::Pass
      current_frame.push(nil)
      return_from_method
    when Bytecode::Apply
      apply
    when Bytecode::Closure
      current_frame.push(ClosureContext.new(instruction, ip, current_frame))
      jump_to(ip + instruction.instructions_size)
    when Bytecode::Close
      close
    when Bytecode::Up
      current_frame.up(instruction.index, instruction.distance)
    else
      raise SpellInvalidBytecodeError.new("Invalid bytecode: #{instruction.inspect}")
    end
    if debug?
      puts "frame after: " + current_frame.inspect
    end
  end

  def invoke_method(name)
    if BINARY_PRIMITIVES.include?(name)
      binary_primitive(name)
    else
      instruction = @instructions.find { |instruction| instruction.is_a?(Bytecode::Label) && instruction.name == name }
      if instruction
        enter(instruction.arguments_size + instruction.bindings_size, current_frame.arguments(instruction.arguments_size))
        jump_to(ip_of(instruction))
      else
        primitive = primitive_for(name)
        if primitive
          current_frame.push(primitive.call(*current_frame.arguments(primitive.arity)))
        else
          raise SpellInvalidMethodCallError.new("Invalid method \"#{name}\" called")
        end
      end
    end
  end

  def return_from_method
    return_value = current_frame.pop
    jump_to(current_frame.return_ip)
    leave
    current_frame.push(return_value)
  end

  def apply
    arguments = current_frame.closure_arguments
    context = arguments.shift
    enter_closure(context, arguments)
    jump_to(context.ip)
  end

  def close
    return_value = current_frame.pop
    jump_to(current_frame.return_ip)
    leave_closure
    current_frame.push(return_value)
  end

  def binary_primitive(primitive)
    operand1, operand2 = current_frame.arguments(2)
    current_frame.push(operand1.send(primitive, operand2))
  end

  def primitive_for(name)
    @primitives[name]
  end

end
