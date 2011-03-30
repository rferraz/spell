class Compiler

  def initialize(code, debug = false, *root_paths)
    @debug = debug
    @code = code
    @root_paths = root_paths
  end

  def run
    passes(false).run(@code)
  end
  
  def dump
    passes(true).run(@code)
  end

  def self.run(code)
    new(code).send(debug ? :dump : :run)
  end
  
  protected
  
  def passes(dump)
    PassManager.
      chain(Prelude).
      chain(Parser, @root_paths).
      chain(Analyzer, LLVMCodeGenerator::PRIMITIVES).
      chain(LLVMCodeGenerator, @debug).
      chain(LLVMRunner, dump)
  end
  
end
