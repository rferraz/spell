class Scope

  def initialize(parent_scope = nil)
    @parent_scope = parent_scope
    @literal_table = []
    @values_table = []
    @symbol_table = SymbolTable.new
  end

  def add_literal(value)
    if index = @literal_table.index(value)
      index
    else
      @literal_table << value
      @literal_table.size - 1
    end
  end

  def value_index(name)
    @values_table.index(name)
  end

  def add_method(method)
    @symbol_table.add(method.name, method, false)
  end

  def add_statement(statement)
    @values_table += statement.arguments
    @values_table += statement.bindings.collect(&:name)
    @symbol_table.add_arguments(statement.arguments)
    @symbol_table.add_bindings(statement.bindings)
  end

  def literal_frame
    @literal_table
  end

  def root_scope?
    @parent_scope.nil?
  end

  def top_scope?
    @parent_scope && @parent_scope.root_scope?
  end

  def find_symbol(symbol_name)
    @symbol_table.find(symbol_name) || (@parent_scope ? @parent_scope.find_symbol(symbol_name) : nil)
  end

end
