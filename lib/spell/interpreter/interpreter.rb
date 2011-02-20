class Interpreter

  def initialize(code, debug, *root_paths)
    @debug = debug
    @code = code
    @root_paths = root_paths
    @primitives = {}
  end

  def attach_primitive(name, method)
    @primitives[name] = method
  end

  def attach_primitives(primitives)
    @primitives.merge!(primitives)
  end

  def run
    ast = Analyzer.analyze(Parser.parse(@code, @root_paths), @primitives.keys + VM::PRIMITIVES)
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
