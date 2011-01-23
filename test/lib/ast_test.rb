require File.join(File.dirname(__FILE__), "..", "test_helper")

class AstTestCase < Test::Unit::TestCase

  SCRIPTS_PATH = File.join(File.dirname(__FILE__), "..", "examples", "scripts", "*.spell")
  AST_PATH = File.join(File.dirname(__FILE__), "..", "examples", "asts", "*.ast")

  def setup
    @parser = SpellParser.new
  end

  def test_parser
    Dir[SCRIPTS_PATH].each do |file|
      ast_file = file.sub("scripts", "asts").sub(".spell", ".ast")
        assert File.exists?(ast_file), "in finding #{ast_file}"
        assert_equal(File.read(ast_file).gsub(/\r|\n/, "").gsub(/\s+/, " ").gsub("\\\"", ""),
                     sexp_to_string(@parser.parse(File.read(file)).build.to_sexp),
                     "for file #{file}")
    end
  end

end

