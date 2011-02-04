require File.join(File.dirname(__FILE__), "..", "test_helper")

class ParserTestCase < Test::Unit::TestCase

  EXAMPLES_PATH = File.join(File.dirname(__FILE__), "..", "examples", "scripts", "*.spell")

  def test_parser
    Dir[EXAMPLES_PATH].each do |file|
      assert_nothing_raised("in file #{file}") do
        Parser.parse(File.read(file))
      end
    end
  end

end
