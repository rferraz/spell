class Scope

  attr_reader :symbol_table

  def initialize(parent_scope = nil)
    @parent_scope = parent_scope
    @literal_table = []
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

  def literal_frame
    @literal_table
  end

  def root_scope?
    @parent_scope.nil?
  end

  def top_scope?
    @parent_scope && @parent_scope.root_scope?
  end

end
