class Analyzer

  def analyze(ast)
    reset_environment
    analyze_all(ast)
    create_program
  end

  def self.analyze(ast)
    new.analyze(ast)
  end

  def method_missing(method, *args, &block)
    if method.to_s =~ /^analyze_(.*)$/
      raise "The class #{$1} is not a valid AST node"
    else
      super
    end
  end

  protected

  def reset_environment
    reset_scopes
    reset_method_table
  end

  def analyze_all(ast)
    analyze_any(ast)
  end

  def create_program
    Ast::Program.new(top_methods)
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
      method = Ast::Method.new(statement.name,
                               current_scope.literal_frame,
                               statement.body.collect { |expression| analyze_any(expression) })
      current_scope.symbol_table.add(statement.name, method, current_scope.top_scope?)
      top_methods << method
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
    @top_methods = []
  end

  def top_methods
    @top_methods
  end

  def current_scope
    @scopes.last
  end

  def root_scope
    @scopes.first
  end

  def enter_scope
    @scopes.push(Scope.new(current_scope))
  end

  def leave_scope
    @scopes.pop
  end

end
