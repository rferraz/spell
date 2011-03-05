class SymbolTable

  def initialize
    @symbols = {}
  end

  def add(name, reference, aliased_name = nil)
    entry = SymbolTableEntry.new(aliased_name || name, reference)
    @symbols[name] = entry
    @symbols[aliased_name] = entry if aliased_name
  end

  def add_arguments(arguments)
    arguments.each { |argument| add(argument, :argument) }
  end

  def add_bindings(bindings)
    bindings.each { |binding| add(binding.name, :binding) }
  end

  def find(name)
    @symbols[name]
  end

end

class SymbolTableEntry

  attr_reader :name
  attr_reader :reference

  def initialize(name, reference)
    @name, @reference = name, reference
  end

end
