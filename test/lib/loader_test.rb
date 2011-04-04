require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

class LoaderTestCase < Test::Unit::TestCase
  
  PRIMITIVES = %w(> <)
  
  CODE = <<-EOF
    main () = 
      ? x < 1 -> a.b
      ? x > 1 -> c[0]
      with
        x () = 1
        a <- { b: 1 }
        c <- [1, 2, 3, 4]
  EOF
  
  def test_dumper
    assert_equal compile(CODE).collect(&:inspect).join, load(dump(CODE)).collect(&:inspect).join
  end
  
  def dump(code)
    PassManager.
      chain(Parser).
      chain(Analyzer, PRIMITIVES).
      chain(BytecodeGenerator).
      chain(Dumper).
      run(code)
  end
  
  def load(dump)
    PassManager.
      chain(Loader).
      run(dump)
  end
  
  def compile(code)
    PassManager.
      chain(Parser).
      chain(Analyzer, PRIMITIVES).
      chain(BytecodeGenerator).
      run(code)
  end
  
end
