require File.join(File.dirname(__FILE__), "..", "test_helper")

class LLVMTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end
  
  PRIMITIVES = %w(+ - * / == assert)
  
  SCRIPTS_PATH = File.join(File.dirname(__FILE__), "..", "examples", "llvm", "*.spell")
  STDLIB_PATH = File.join(File.dirname(__FILE__), "..", "..", "stdlib")
  
  files = Dir[SCRIPTS_PATH]

  raise "No target files found for the LLVM code generator test in #{SCRIPTS_PATH}" if files.empty?

  Dir[SCRIPTS_PATH].each do |file|
    
    define_method("test_" + File.basename(file, ".spell")) do
      code = File.read(file)
      type, value = result_for(code)
      result = formatted_result_for(execute(code, false), type)
      if type == "float"
        assert_in_delta value, result, 0.00001
      else
        assert_equal value, result
      end
    end

  end
  
  def execute(code, debug)
    builder = PassManager.
      chain(Parser, [STDLIB_PATH]).
      chain(Analyzer, PRIMITIVES).
      chain(LLVMCodeGenerator, PrimitiveBuilder).
      run(code)
    builder.verified_module.dump if debug
    result = LLVM::ExecutionEngine.
      create_jit_compiler(builder.verified_module).
      run_function(builder.default_function)
    result.to_ptr.read_pointer
  end

  class FloatValue < FFI::Struct
    layout :value, :float 
  end

  class StringValue < FFI::Struct
    layout :value, :pointer 
  end
  
  class ExceptionValue < FFI::Struct
    layout :value, :pointer 
  end

  class Box < FFI::Union
    layout :float, FloatValue,
           :exception, ExceptionValue,
           :string, StringValue
  end
  
  class Value < FFI::Struct
    layout :flag, :long,
           :box, Box
  end
  
  def result_for(code)
    type, result = code.lines.first.strip.split(":").last.split(",").collect(&:strip)
    value = case type
    when "integer"
      case result
      when "true"
        1
      when "false"
        0
      else
        result.to_i
      end
    when "float"
      result.to_f
    when "string"
      result
    when "exception"
      result
    else
      raise "Unknown type"
    end
    [type, value]
  end

  def formatted_result_for(result, type)
    case type
    when "integer"
      result.to_i >> 1
    when "float"
      Value.new(result)[:box][:float][:value]
    when "string"
      Value.new(result)[:box][:string][:value].read_string_to_null
    when "exception"
      Value.new(Value.new(result)[:box][:exception][:value])[:box][:string][:value].read_string_to_null
    else
      raise "Unknown type"
    end
  end
  
  class PrimitiveBuilder
    
    def self.build(builder)
    end
    
  end

end

