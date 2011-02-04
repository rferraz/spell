require File.join(File.dirname(__FILE__), "..", "test_helper")

SCRIPTS_PATH = File.join(File.dirname(__FILE__), "..", "examples", "interpreter", "*.spell")

Dir[SCRIPTS_PATH].each do |file|

  Class.new(Test::Unit::TestCase) do

    define_method("test_" + File.basename(file, ".spell")) do
      flunk
      Interpreter.run(File.read(file))
    end

  end

end

