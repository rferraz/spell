require File.join(File.dirname(__FILE__), "..", "test_helper")

class AstTestCase < Test::Unit::TestCase

  SCRIPTS_PATH = File.join(File.dirname(__FILE__), "..", "examples", "parser", "scripts", "*" + SPELL_EXTENSION)
  AST_PATH = File.join(File.dirname(__FILE__), "..", "examples", "parser", "asts", "*" + AST_EXTENSION)

  files = Dir[SCRIPTS_PATH]

  raise "No target files found for the AST test in #{SCRIPTS_PATH}" if files.empty?

  files.each do |file|

    define_method("test_" + File.basename(file, SPELL_EXTENSION)) do
      ast_file = file.sub("scripts", "asts").sub(SPELL_EXTENSION, AST_EXTENSION)
      assert File.exists?(ast_file), "in finding #{ast_file}"
      assert_equal(cleanup_sexp(File.read(ast_file)),
                   sexp_to_string(parse(File.read(file), File.dirname(SCRIPTS_PATH)).to_sexp),
                   "for file #{file}")
    end

  end
  
  def parse(code, root_path)
    PassManager.chain(Parser, root_path).run(code)
  end
  

end

