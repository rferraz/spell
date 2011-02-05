require File.join(File.dirname(__FILE__), "..", "test_helper")

class AnalyzerTestCase < Test::Unit::TestCase

  SCRIPTS_PATH = File.join(File.dirname(__FILE__), "..", "examples", "analyzer", "scripts", "*" + SPELL_EXTENSION)
  AST_PATH = File.join(File.dirname(__FILE__), "..", "examples", "analyzer", "analyzed", "*" + AST_EXTENSION)

  files = Dir[SCRIPTS_PATH]

  raise "No target files found for the analyzer test in #{SCRIPTS_PATH}" if files.empty?

  files.each do |file|

    define_method("test_" + File.basename(file, SPELL_EXTENSION)) do
      ast_file = file.sub("scripts", "analyzed").sub(SPELL_EXTENSION, AST_EXTENSION)
      assert File.exists?(ast_file), "in finding #{ast_file}"
      assert_equal(cleanup_sexp(File.read(ast_file)),
                   sexp_to_string(Analyzer.analyze(Parser.parse(File.read(file))).to_sexp),
                   "for file #{file}")
    end

  end

end
