require File.join(File.dirname(__FILE__), "..", "test_helper")

class InterpreterTestCase < Test::Unit::TestCase

  SCRIPTS_PATH = File.join(File.dirname(__FILE__), "..", "examples", "interpreter", "*.spell")

  files = Dir[SCRIPTS_PATH]

  raise "No target files found for the interpreter test in #{SCRIPTS_PATH}" if files.empty?

  Dir[SCRIPTS_PATH].each do |file|

    define_method("test_" + File.basename(file, ".spell")) do
      code = File.read(file)
      interpreter = Interpreter.new(code, false)
      initialize_primitives(interpreter)
      assert_equal result_for(code), formatted_result_for(interpreter.run)
    end

  end

  def initialize_primitives(interpreter)
      interpreter.attach_primitive("assert#equal", method(:primitive_assert_equal))
      interpreter.attach_primitive("null", method(:primitive_null))
      interpreter.attach_primitive("head", method(:primitive_head))
      interpreter.attach_primitive("tail", method(:primitive_tail))
      interpreter.attach_primitive(":", method(:primitive_cons))
  end

  def primitive_assert_equal(expected, actual)
    assert_equal(expected, actual)
    actual || :nothing
  end

  def primitive_null(list)
    list.empty?
  end

  def primitive_head(list)
    list.first
  end

  def primitive_tail(list)
    first, *rest = list
    rest
  end

  def primitive_cons(element, list)
    list.unshift(element)
    list
  end

  def result_for(code)
    code.lines.first.strip
  end

  def formatted_result_for(result)
    "# Result: #{result}"
  end

end

