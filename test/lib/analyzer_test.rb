require File.join(File.dirname(__FILE__), "..", "test_helper")

class AnalyzerTestCase < Test::Unit::TestCase

  SCRIPTS_PATH = File.join(File.dirname(__FILE__), "..", "examples", "analyzer", "scripts", "*" + SPELL_EXTENSION)
  AST_PATH = File.join(File.dirname(__FILE__), "..", "examples", "analyzer", "analyzed", "*" + AST_EXTENSION)

  INVALID_SCRIPTS_PATH = File.join(File.dirname(__FILE__), "..", "examples", "analyzer", "invalid", "*" + SPELL_EXTENSION)

  ANALYZER_TEST_PRIMITIVES = %w(+ - * / < > <= >= ** : ++ , apply & | !)

  files = Dir[SCRIPTS_PATH]

  raise "No target files found for the analyzer test in #{SCRIPTS_PATH}" if files.empty?

  files.each do |file|

    define_method("test_" + File.basename(file, SPELL_EXTENSION)) do
      ast_file = file.sub("scripts", "analyzed").sub(SPELL_EXTENSION, AST_EXTENSION)
      assert File.exists?(ast_file), "in finding #{ast_file}"
      assert_equal(cleanup_sexp(File.read(ast_file)),
                   sexp_to_string(Analyzer.analyze(Parser.parse(File.read(file)), ANALYZER_TEST_PRIMITIVES).to_sexp),
                   "for file #{file}")
    end

  end

  invalid_files = Dir[INVALID_SCRIPTS_PATH]

  raise "No invalid target files found for the analyzer test in #{INVALID_SCRIPTS_PATH}" if files.empty?

  invalid_files.each do |file|

    define_method("test_" + File.basename(file, SPELL_EXTENSION)) do
      code = File.read(file)
      assert File.exists?(file), "in finding #{file}"
      assert_raise_with_message(SpellAnalyzerError, error_message_for(code)) do
        Analyzer.analyze(Parser.parse(code))
      end
    end

  end

  def test_primitive
    assert_nothing_raised do
      Analyzer.analyze(Parser.parse("main () = primitive"), ["primitive"])
    end
  end

  def error_message_for(code)
    code.lines.first.gsub("#", "").strip
  end

end
