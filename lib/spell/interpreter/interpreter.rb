class Interpreter

  def initialize(code, debug, *root_paths)
    @debug = debug
    @code = code
    @root_paths = root_paths
    @primitives = {}
  end

  def attach_primitive(name, method)
    @primitives[name] = method
  end

  def attach_primitives(primitives)
    @primitives.merge!(primitives)
  end

  def run
    passes.run(@code)
  end

  def self.run(code)
    new(code).run
  end
  
  protected
  
  def passes
    PassManager.
      chain(Parser, @root_paths).
      chain(Analyzer, @primitives.keys + VM::PRIMITIVES).
      chain(BytecodeGenerator).
      chain(VM, @primitives, @debug)
  end

end
