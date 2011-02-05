class SymbolTable

  def initialize
    @symbols = {}
  end

  def add(name, reference, global)
    @symbols[name] = SymbolTableEntry.new(name, reference, global)
  end

  def find(name)
    @symbols[name]
  end

  def new_unique_name(name)
    if @symbols[name]
      name
    else
      name
    end
  end

end

class SymbolTableEntry

  def initialize(name, reference, global)
    @name, @reference, @global = name, reference, global
  end

end
