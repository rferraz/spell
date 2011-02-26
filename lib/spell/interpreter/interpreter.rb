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
    if is_dump?
      load_passes.run(@code)
    else
      run_passes.run(@code)
    end
  end
  
  def dump
    puts dump_passes.run(@code)
  end

  def self.run(code)
    new(code).run
  end
  
  protected
  
  def is_dump?
    @code.starts_with?(Dumper::HEADER)
  end
  
  def run_passes
    PassManager.
      chain(Parser, @root_paths).
      chain(Analyzer, @primitives.keys + VM::PRIMITIVES).
      chain(BytecodeGenerator).
      chain(VM, @primitives, @debug)
  end

  def dump_passes
    PassManager.
      chain(Parser, @root_paths).
      chain(Analyzer, @primitives.keys + VM::PRIMITIVES).
      chain(BytecodeGenerator).
      chain(Dumper)
  end
  
  def load_passes
    PassManager.
      chain(Loader).
      chain(VM, @primitives, @debug)
  end

end
