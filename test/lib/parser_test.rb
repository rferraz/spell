require File.join(File.dirname(__FILE__), "..", "test_helper")

class ParserTestCase < Test::Unit::TestCase

  EXAMPLES_PATH = File.join(File.dirname(__FILE__), "..", "examples", "*.spell")

  def setup
    @parser = Parser.new
  end

  def test_parser
    Dir[EXAMPLES_PATH].each do |file|
      assert @parser.parse(File.read(file))
    end
  end

end
