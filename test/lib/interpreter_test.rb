require File.join(File.dirname(__FILE__), "..", "test_helper")

class InterpreterTestCase < Test::Unit::TestCase

  EXAMPLES_PATH = File.join(File.dirname(__FILE__), "..", "examples", "interpreter")
  
  SCRIPTS_PATH = File.join(EXAMPLES_PATH, "*.spell")
  
  DUMP_PATH = File.join(EXAMPLES_PATH, "graham.dump")

  files = Dir[SCRIPTS_PATH]

  raise "No target files found for the interpreter test in #{SCRIPTS_PATH}" if files.empty?

  Dir[SCRIPTS_PATH].each do |file|
    
    define_method("test_" + File.basename(file, ".spell")) do
      code = File.read(file)
      assert_equal result_for(code), formatted_result_for(interpreter_instance(code).run)
    end

  end
  
  def test_dump
    assert_equal "right\n", interpreter_instance(File.read(DUMP_PATH)).run
  end
  
  def interpreter_instance(code)
    interpreter = Interpreter.new(code, false)
    initialize_primitives(interpreter)
    interpreter
  end

  def initialize_primitives(interpreter)
    interpreter.attach_primitive("assert#equal", method(:primitive_assert_equal))
    interpreter.attach_primitive("error#signal", Exception.method(:new))
    interpreter.attach_primitive("show", method(:primitive_show))
  end

  def primitive_assert_equal(expected, actual)
    assert_equal(expected, actual)
    actual || :nothing
  end
  
  def primitive_show(value)
    value
  end

  def result_for(code)
    code.lines.first.strip
  end

  def formatted_result_for(result)
    "# Result: #{result}"
  end

end

