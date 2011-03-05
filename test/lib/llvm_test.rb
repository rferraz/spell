require File.join(File.dirname(__FILE__), "..", "test_helper")

class LLVMTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end
  
  PRIMITIVES = %w(
    + - * /
    assert#equal null head tail length : ++ 
    math#round math#sqrt error#signal show
  )
  
  SCRIPTS_PATH = File.join(File.dirname(__FILE__), "..", "examples", "llvm", "*.spell")
  
  files = Dir[SCRIPTS_PATH]

  raise "No target files found for the LLVM code generator test in #{SCRIPTS_PATH}" if files.empty?

  Dir[SCRIPTS_PATH].each do |file|
    
    define_method("test_" + File.basename(file, ".spell")) do
      code = File.read(file)
      assert_equal result_for(code), formatted_result_for(execute(code))
    end

  end
  
  def execute(code)
    builder = PassManager.
      chain(Parser).
      chain(Analyzer, PRIMITIVES).
      chain(LLVMCodeGenerator, PrimitiveBuilder).
      run(code)
    builder.verified_module.dump
    LLVM::ExecutionEngine.
      create_jit_compiler(builder.verified_module).
      run_function(builder.default_function).to_ptr.read_pointer.read_float
  end
  
  def result_for(code)
    code.lines.first.strip
  end

  def formatted_result_for(result)
    "# Result: #{result}"
  end
  
  class PrimitiveBuilder
    
    def self.build(builder)
    end
    
  end

end

