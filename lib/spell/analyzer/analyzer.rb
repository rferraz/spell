class Analyzer

  PRIMITIVES = %w(+ - * / < >)

  def analyze(ast)
    reset_environment
    analyze_all(ast)
    fix_unresolved
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
    reset_unresolved
  end

  def create_program
    Ast::Program.new(top_methods)
  end

  def fix_unresolved
    unresolved.each do |invoke|
      if PRIMITIVES.include?(invoke.message)
        invoke.resolve!
      elsif top_methods.find { |method| method.name == invoke.message }
        invoke.resolve!
      else
        raise SpellAnalyzerError.new("Undefined method #{invoke.message}")
      end
    end
  end

  def analyze_all(ast)
    analyze_any(ast)
  end

  def analyze_any(ast)
    send("analyze_#{ast.class.name.demodulize.underscore}", ast)
  end

  def analyze_list(list)
    list.collect { |item| analyze_any(item) }
  end

  def analyze_program(program)
    analyze_list(program.statements)
  end

  def analyze_statement(statement)
    enter_scope
    begin
      current_scope.add_statement(statement)
      assignments, statements = statement.bindings.partition { |binding| binding.is_a?(Ast::Assignment) }
      analyze_list(statements)
      method = Ast::Method.new(unique_method_name(statement),
                               statement.arguments.size,
                               assignments.size,
                               current_scope.literal_frame,
                               analyze_list(assignments) + analyze_list(statement.body))
      if current_scope.top_scope?
        current_scope.add_method(method)
      else
        current_scope.parent_scope.add_method(method, statement.name)
      end
      top_methods << method
    ensure
      leave_scope
    end
  end

  def analyze_expression(expression)
    analyze_any(expression.body)
  end

  def analyze_assignment(assignment)
    Ast::Store.new(:value, current_scope.value_index(assignment.name), analyze_any(assignment.expression))
  end

  def analyze_invoke(invoke)
    symbol = current_scope.find_symbol(invoke.message)
    if symbol
      case symbol.reference
      when Ast::Method
        Ast::Invoke.new(symbol.reference.name, analyze_list(invoke.parameters))
      when Ast::Assignment
        Ast::Load.new(:value, current_scope.value_index(symbol.reference.name))
      else
        Ast::Load.new(:value, current_scope.value_index(symbol.reference))
      end
    else
      unresolved << Ast::Invoke.new(invoke.message, analyze_list(invoke.parameters), false)
      unresolved.last
    end
  end

  def analyze_case(case_statement)
    Ast::Case.new(analyze_list(case_statement.items))
  end

  def analyze_case_item(case_item)
    Ast::CaseItem.new(analyze_any(case_item.condition), analyze_any(case_item.result))
  end

  def analyze_default_case_item(default_case_item)
    default_case_item
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

  def reset_unresolved
    @unresolved = []
  end

  def unresolved
    @unresolved
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

  def unique_method_name(statement)
    if current_scope.top_scope?
      name = statement.name
    else
      root_name = "__inner__" + statement.name
      root_name + "__" + (top_methods.collect(&:name).grep(/#{root_name}/).size + 1).to_s
    end
  end

end
