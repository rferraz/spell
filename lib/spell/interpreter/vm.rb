class VM

  BINARY_PRIMITIVES = %w(+ - * / ** & | < > <= >= ==)

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
    @frames = [Frame.new(ip)]
  end

  def enter(frame)
    @frames.push(frame)
  end

  def leave
    @frames.pop
  end

  def current_frame
    @frames.last
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
      call_method(instruction.method)
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
    when Bytecode::Return
      return_from_method
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
    else
      raise SpellInvalidBytecodeError.new("Invalid bytecode: #{instruction.inspect}")
    end
    if debug?
      puts "frame after: " + current_frame.inspect
    end
  end

  def call_method(name)
    if BINARY_PRIMITIVES.include?(name)
      binary_primitive(name)
    else
      instruction = @instructions.find { |instruction| instruction.is_a?(Bytecode::Label) && instruction.name == name }
      if instruction
        enter(Frame.new(ip, instruction.arguments_size + instruction.bindings_size, arguments(instruction.arguments_size)))
        jump_to(ip_of(instruction))
      else
        primitive = primitive_for(name)
        if primitive
          current_frame.push(primitive.call(*arguments(primitive.arity)))
        else
          raise SpellInvalidMethodCallError.new("Invalid method \"#{name}\" called")
        end
      end
    end
  end

  def binary_primitive(primitive)
    current_frame.push(current_frame.pop.send(primitive, current_frame.pop))
  end

  def return_from_method
    return_value = current_frame.pop
    jump_to(current_frame.return_ip)
    leave
    current_frame.push(return_value)
  end

  def primitive_for(name)
    @primitives[name]
  end

  def arguments(count)
    parameters = []
    count.times { parameters.push(current_frame.pop) }
    parameters
  end

end
