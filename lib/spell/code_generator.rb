class CodeGenerator

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
    program.statements.inject([]) { |memo, statement| memo += generate_any(statement) ; memo }
  end

  def generate_statement(statement)
    statement.body.inject([]) { |memo, expression| memo += generate_any(expression) ; memo }
  end

  def generate_expression(expression)
    generate_any(expression.body)
  end

  def generate_invoke(invoke)
    [:invoke, invoke.message]
  end

end

