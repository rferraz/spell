class Analyzer

  def initialize(*primitives)
    @primitives = *primitives
  end
  
  def run(ast)
    reset_environment
    analyze_all(ast)
    fix_unresolved
    create_program
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
    verify_main
    Ast::Program.new(top_methods)
  end

  def fix_unresolved
    unresolved.each do |invoke|
      if primitives.include?(invoke.message)
        invoke.resolve!
      elsif top_methods.find { |method| method.name == invoke.message }
        invoke.resolve!
      else
        raise SpellAnalyzerError.new("Undefined method \"#{invoke.message}\"")
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
      new_name = unique_method_name(statement)
      if current_scope.top_scope?
        current_scope.add_method(statement.name)
      else
        current_scope.parent_scope.add_method(new_name, statement.name)
      end
      analyze_list(statements)
      method = Ast::Method.new(new_name,
                               statement.arguments.size,
                               assignments.size,
                               current_scope.literal_frame,
                               analyze_list(assignments) + analyze_list(statement.body))
      check_for_duplication(method, statement.name)
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
    symbol, origin_scope = current_scope.find_symbol(invoke.message)
    if symbol
      case symbol.reference
      when :method
        Ast::Invoke.new(symbol.name, analyze_list(invoke.parameters))
      when :binding
        if origin_scope == current_scope
          Ast::Load.new(:value, current_scope.value_index(symbol.name))
        else
          Ast::Up.new(origin_scope.value_index(symbol.name), current_scope.distance_from(origin_scope))
        end
      else
        if origin_scope == current_scope
          Ast::Load.new(:value, current_scope.value_index(symbol.name))
        else
          Ast::Up.new(origin_scope.value_index(symbol.name), current_scope.distance_from(origin_scope))
        end
      end
    else
      unresolved << Ast::Invoke.new(invoke.message, analyze_list(invoke.parameters), false)
      unresolved.last
    end
  end

  def analyze_case(case_statement)
    Ast::Case.new(analyze_list(reorder_case_items(case_statement.items)))
  end

  def analyze_case_item(case_item)
    Ast::CaseItem.new(analyze_any(case_item.condition), analyze_any(case_item.result))
  end

  def analyze_null_case_condition(null_case_condition)
    null_case_condition
  end

  def analyze_dictionary_literal(dictionary)
    Ast::DictionaryLiteral.new(analyze_list(dictionary.items))
  end

  def analyze_dictionary_item(dictionary_item)
    Ast::DictionaryItem.new(dictionary_item.name, analyze_any(dictionary_item.expression))
  end

  def analyze_dictionary_access(dictionary_access)
    Ast::DictionaryAccess.new(analyze_any(dictionary_access.target), dictionary_access.accessor)
  end

  def analyze_array_literal(array)
    Ast::ArrayLiteral.new(analyze_list(array.items))
  end

  def analyze_array_item(array_item)
    Ast::ArrayItem.new(analyze_any(array_item.expression))
  end

  def analyze_array_access(array_access)
    Ast::ArrayAccess.new(analyze_any(array_access.target), analyze_any(array_access.index))
  end

  def analyze_block(block)
    enter_scope
    begin
      current_scope.add_block(block)
      Ast::Closure.new(block.arguments.size,
                       current_scope.literal_frame,
                       analyze_list(block.body))
    ensure
      leave_scope
    end
  end

  def analyze_primitive(primitive)
    primitive
  end

  def analyze_literal(literal)
    Ast::Load.new(:const, current_scope.add_literal(literal.value))
  end

  def analyze_pass(pass)
    pass
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

  def primitives
    @primitives || []
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

  def check_for_duplication(method, real_name)
    raise SpellAnalyzerError.new("Duplicate method \"#{real_name}\"") if top_methods.collect(&:name).include?(method.name)
  end

  def reorder_case_items(items)
    default, conditions = items.partition { |item| item.condition.is_a?(Ast::NullCaseCondition) }
    conditions + default
  end
  
  def verify_main
    main = top_methods.find { |method| method.name == ORIGINAL_MAIN_METHOD_NAME }
    raise SpellAnalyzerError.new("Missing \"main\" method") unless main
    raise SpellAnalyzerError.new("Method \"main\" should have no parameters") unless main.arguments_size.zero?
  end

end
