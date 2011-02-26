require File.join(File.dirname(__FILE__), "..", "test_helper")

class DumperTestCase < Test::Unit::TestCase
  
  def test_dumper
    assert_equal "SPELL\n\nlabel main 0 0 1\npush integer 1\nload const 0\nreturn\ninvoke main", dump("main () = 1")
  end
  
  def dump(code)
    PassManager.
      chain(Parser).
      chain(Analyzer).
      chain(BytecodeGenerator).
      chain(Dumper).
      run(code)
  end
  
end
