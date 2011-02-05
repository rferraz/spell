class Analyser

  def initialize(ast)
    @ast = ast
  end

  def analyse
    reset_scopes
    reset_method_table
    reset_symbol_table
    analyze_all
    Ast::Program.new(@methods)
  end

  def self.analyze(ast)
    new(ast).analyse
  end

  def method_missing(method, *args, &block)
    if method.to_s =~ /^analyze_(.*)$/
      raise "The class #{$1} is not a valid AST node"
    else
      super
    end
  end

  protected

  def analyze_all
    analyze_any(@ast)
  end

  def analyze_any(ast)
    send("analyze_#{ast.class.name.demodulize.underscore}", ast)
  end

  def analyze_program(program)
    program.statements.collect { |statement| analyze_any(statement) }
  end

  def analyze_statement(statement)
    enter_scope
    begin
      @methods << Ast::Method.new(statement.name,
                                 current_scope.literal_frame,
                                 statement.body.collect { |expression| analyze_any(expression) })
    ensure
      leave_scope
    end
  end

  def analyze_expression(expression)
    analyze_any(expression.body)
  end

  def analyze_literal(literal)
    Ast::Load.new(:const, current_scope.add_literal(literal.value))
  end

  def analyze_pass(pass)
    Ast::Return.new
  end

  def reset_scopes
    @scopes = [Scope.new]
  end

  def reset_method_table
    @methods = []
  end

  def reset_symbol_table
    @symbol_table = []
  end

  def current_scope
    @scopes.last
  end

  def enter_scope
    @scopes.push(Scope.new)
  end

  def leave_scope
    @scopes.pop
  end

end
