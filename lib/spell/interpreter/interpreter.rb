class Interpreter

  def initialize(code, debug)
    @debug = debug
    @code = code
    @primitives = {}
  end

  def attach_primitive(name, method)
    @primitives[name] = method
  end

  def run
    ast = Analyzer.analyze(Parser.parse(@code), @primitives.keys + VM::PRIMITIVES)
    if ast
      instructions = BytecodeGenerator.new(ast).generate
      vm = VM.new(instructions, @primitives, @debug)
      vm.run
    else
      raise @parser.failure_reason
    end
  end

  def self.run(code)
    new(code).run
  end

end
