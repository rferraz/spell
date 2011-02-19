class BytecodeGenerator

  def initialize(ast)
    @ast = ast
  end

  def generate
    generate_any(@ast)
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

  def generate_program(program)
    instructions = program.statements.inject([]) { |memo, statement| memo += generate_any(statement) ; memo }
    instructions << Bytecode::Invoke.new("main")
    instructions
  end

  def generate_method(method)
    instructions = [Bytecode::Label.new(method.name, method.literal_frame.size, method.bindings_size)]
    method.literal_frame.each do |literal|
      instructions << Bytecode::Push.new(literal)
    end
    instructions += method.body.inject([]) { |memo, expression| memo += generate_any(expression) ; memo }
    instructions << Bytecode::Return.new
    instructions
  end

  def generate_expression(expression)
    generate_any(expression.body)
  end
  
  def generate_load(load)
    [Bytecode::Load.new(load.type, load.index)]
  end

  def generate_invoke(invoke)
    instructions = []
    invoke.parameters.reverse.each do |parameter|
      instructions += generate_any(parameter)
    end
    instructions << Bytecode::Invoke.new(invoke.message)
    instructions
  end
  
end

