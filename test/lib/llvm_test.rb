require File.join(File.dirname(__FILE__), "..", "test_helper")

class LLVMTestCase < Test::Unit::TestCase

  SCRIPTS_PATH = File.join(File.dirname(__FILE__), "..", "examples", "llvm", "*.spell")
  STDLIB_PATH = File.join(File.dirname(__FILE__), "..", "..", "stdlib")
  
  files = Dir[SCRIPTS_PATH]

  raise "No target files found for the LLVM code generator test in #{SCRIPTS_PATH}" if files.empty?

  Dir[SCRIPTS_PATH].each do |file|
    
    define_method("test_" + File.basename(file, ".spell")) do
      code = File.read(file)
      value = result_for(code)
      result = formatted_result_for(execute(code, false))
      if value.is_a?(Float)
        assert_in_delta value, result, 0.00001
      else
        assert_equal value, result
      end
    end

  end
  
  def execute(code, dump)
    compiler = Compiler.new(code, true, STDLIB_PATH)
    result = dump ? compiler.dump : compiler.run
    result.to_ptr.read_pointer
  end

  class FloatValue < FFI::Struct
    layout :value, :float 
  end

  class StringValue < FFI::Struct
    layout :length, :long,
            # FIX: don't know how to handle variable length arrays
            # from FFI so we're temporarily limiting them to 1kb
            # which should be enough for the tests (this doesn't
            # affect the internal working of the generator)
           :value, [:char, 1024] 
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
    case type
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
      raise "Unknown type in the result assertion"
    end
  end

  def formatted_result_for(result)
    if (result.to_i & 1) == 1
      result.to_i >> 1
    else
      value = Value.new(result)
      case value[:flag]
      when EXCEPTION_FLAG
        "[Exception] " + Value.new(value[:box][:exception][:value])[:box][:string][:value]
      when FLOAT_FLAG
        value[:box][:float][:value]
      when STRING_FLAG
        value[:box][:string][:value].to_s
      when ARRAY_FLAG
        raise "Cannot inspect array in the formatted result"
      when DICTIONARY_FLAG
        raise "Cannot inspect dictionary in the formatted result"
      when CONTEXT_FLAG
        raise "Cannot inspect context in the formatted result"
      else
        raise "Unknown type in the formatted result"
      end
    end
  end
  
end

