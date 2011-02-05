class Scope

  def initialize
    @literal_table = []
  end

  def add_literal(value)
    index = @literal_table.index(value)
    if index
      index
    else
      @literal_table << value
      @literal_table.size - 1
    end
  end

  def literal_frame
    @literal_table
  end

end
