require File.join(File.dirname(__FILE__), "..", "test_helper")

class ParserTestCase < Test::Unit::TestCase

  EXAMPLES_PATH = File.join(File.dirname(__FILE__), "..", "examples", "parser", "scripts", "*" + SPELL_EXTENSION)

  files = Dir[EXAMPLES_PATH]

  raise "No target files found for the parser test in #{EXAMPLES_PATH}" if files.empty?

  files.each do |file|

    define_method("test_" + File.basename(file, SPELL_EXTENSION)) do
      assert_nothing_raised("in file #{file}") do
        parse(File.read(file))
      end
    end

  end
  
  def parse(code)
    PassManager.chain(Parser, File.dirname(EXAMPLES_PATH)).run(code)
  end

end
