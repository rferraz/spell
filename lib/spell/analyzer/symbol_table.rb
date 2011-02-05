class SymbolTable

  def initialize
    @symbols = {}
  end

  def add(name, reference, global)
    @symbols[name] = SymbolTableEntry.new(name, reference, global)
  end

  def add_arguments(arguments)
    arguments.each { |argument| add(argument, argument, false) }
  end

  def add_bindings(bindings)
    bindings.each { |binding| add(binding.name, binding, false) }
  end

  def find(name)
    @symbols[name]
  end

end

class SymbolTableEntry

  attr_reader :name
  attr_reader :reference
  attr_reader :global

  def initialize(name, reference, global)
    @name, @reference, @global = name, reference, global
  end

end
