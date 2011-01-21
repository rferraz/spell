require File.join(File.dirname(__FILE__), "..", "test_helper")

class ParserTestCase < Test::Unit::TestCase

  EXAMPLES_PATH = File.join(File.dirname(__FILE__), "..", "examples", "*.spell")

  def setup
    @parser = SpellParser.new
  end

  def test_parser
    Dir[EXAMPLES_PATH].each do |file|
      assert_not_nil @parser.parse(File.read(file)), "#{@parser.failure_reason} in file #{file}"
    end
  end

end
