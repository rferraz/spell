class Compiler

  def initialize(code, debug = false, output_filename = "a.out", *root_paths)
    @debug = debug
    @code = code
    @output_filename = output_filename
    @root_paths = root_paths
  end

  def run
    run_passes(false).run(@code)
  end
  
  def dump
    run_passes(true).run(@code)
  end
  
  def compile
    compile_passes.run(@code)
  end

  protected
  
  def passes
    PassManager.
      chain(Prelude).
      chain(Parser, @root_paths).
      chain(Analyzer, LLVMCodeGenerator::PRIMITIVES).
      chain(LLVMCodeGenerator, @debug)
  end
  
  def run_passes(dump)
    passes.
      chain(LLVMRunner, dump)
  end
  
  def compile_passes
    passes.
      chain(LLVMCompiler, @output_filename)
  end
  
end
