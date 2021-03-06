class BytecodeGenerator

  def run(ast)
    generate_any(ast)
  end

  def method_missing(method, *args, &block)
    if method.to_s =~ /^generate_(.*)$/
      raise "The class #{$1} is not a valid AST node"
    else
      super
    end
  end

  protected

  def generate_any(ast)
    send("generate_#{ast.class.name.demodulize.underscore}", ast)
  end

  def generate_list(list)
    list.collect { |item| generate_any(item) }.flatten
  end

  def generate_program(program)
    instructions = generate_list(program.statements)
    instructions << Bytecode::Invoke.new("main")
    instructions
  end

  def generate_method(method)
    instructions = [Bytecode::Label.new(method.name, method.arguments_size, method.bindings_size, method.literal_frame.size)]
    method.bindings_size.times do
      instructions << Bytecode::Push.new(nil)
    end
    method.literal_frame.each do |literal|
      instructions << Bytecode::Push.new(eval(literal.to_s))
    end
    instructions += generate_list(method.body)
    instructions << Bytecode::Return.new
    instructions
  end

  def generate_expression(expression)
    generate_any(expression.body)
  end

  def generate_case(case_statement)
    generate_list(case_statement.items)
  end

  def generate_case_item(case_item)
    instructions = []
    if case_item.condition.is_a?(Ast::NullCaseCondition)
      instructions += generate_any(case_item.result)
      instructions << Bytecode::Return.new
    else
      result_instructions = generate_any(case_item.result)
      instructions += generate_any(case_item.condition)
      instructions << Bytecode::JumpFalse.new(result_instructions.size + 1)
      instructions += result_instructions
      instructions << Bytecode::Return.new
    end
    instructions
  end

  def generate_store(store)
    instructions = generate_any(store.body)
    instructions << Bytecode::Store.new(store.type, store.index)
    instructions
  end

  def generate_load(load)
    [Bytecode::Load.new(load.type, load.index)]
  end

  def generate_invoke(invoke)
    instructions = generate_list(invoke.parameters)
    if invoke.message == "apply"
      instructions << Bytecode::Apply.new
    else
      instructions << Bytecode::Invoke.new(invoke.message)
    end
    instructions
  end

  def generate_dictionary_literal(dictionary)
    instructions = [Bytecode::DictionaryNew.new]
    instructions += generate_list(dictionary.items)
    instructions
  end

  def generate_dictionary_item(dictionary_item)
    instructions = generate_any(dictionary_item.expression)
    instructions << Bytecode::DictionarySet.new(dictionary_item.name)
    instructions
  end

  def generate_dictionary_access(dictionary_access)
    instructions = generate_any(dictionary_access.target)
    instructions << Bytecode::DictionaryGet.new(dictionary_access.accessor)
    instructions
  end

  def generate_array_literal(array)
    instructions = [Bytecode::ArrayNew.new]
    instructions += generate_list(array.items)
    instructions
  end

  def generate_array_item(array_item)
    instructions = generate_any(array_item.expression)
    instructions << Bytecode::ArraySet.new
    instructions
  end

  def generate_array_access(array_access)
    instructions = []
    instructions += generate_any(array_access.index)
    instructions += generate_any(array_access.target)
    instructions << Bytecode::ArrayGet.new
    instructions
  end

  def generate_primitive(primitive)
    Bytecode::Invoke.new(primitive.name)
  end

  def generate_pass(pass)
    Bytecode::Pass.new
  end

  def generate_closure(closure)
    instructions = []
    closure.literal_frame.each do |literal|
      instructions << Bytecode::Push.new(eval(literal.to_s))
    end
    instructions += generate_list(closure.body)
    instructions << Bytecode::Close.new
    closure_instruction = Bytecode::Closure.new(closure.arguments_size,
                                                closure.literal_frame.size,
                                                instructions.size)
    [closure_instruction] + instructions
  end

  def generate_up(up)
    [Bytecode::Up.new(up.index, up.distance)]
  end

end

