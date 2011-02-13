class Scope

  attr_reader :parent_scope

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

  def add_method(method, real_name = nil)
    @symbol_table.add(real_name || method.name, method, false)
  end

  def add_statement(statement)
    arguments = statement.arguments
    bindings = statement.bindings.select { |binding| binding.is_a?(Ast::Assignment) }
    @values_table += arguments
    @values_table += bindings.collect(&:name)
    @symbol_table.add_arguments(arguments)
    @symbol_table.add_bindings(bindings)
  end

  def add_block(block)
    @values_table += block.arguments
    @symbol_table.add_arguments(block.arguments)
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
    symbol = @symbol_table.find(symbol_name)
    if symbol
      [symbol, self]
    elsif @parent_scope
      @parent_scope.find_symbol(symbol_name)
    else
      [nil, self]
    end
  end

  def distance_from(scope)
    if scope == self
      0
    elsif @parent_scope
      1 + @parent_scope.distance_from(scope)
    else
      raise SpellUnrelatedScopeError.new
    end
  end

end
