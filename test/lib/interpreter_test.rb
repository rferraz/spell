require File.join(File.dirname(__FILE__), "..", "test_helper")

class InterpreterTestCase < Test::Unit::TestCase

  SCRIPTS_PATH = File.join(File.dirname(__FILE__), "..", "examples", "interpreter", "*.spell")

  files = Dir[SCRIPTS_PATH]

  raise "No target files found for the interpreter test in #{SCRIPTS_PATH}" if files.empty?

  Dir[SCRIPTS_PATH].each do |file|

    define_method("test_" + File.basename(file, ".spell")) do
      interpreter = Interpreter.new(File.read(file))
      interpreter.attach_primitive("assert") { argument | assert(argument) }
      assert interpreter.run
    end

  end

end

