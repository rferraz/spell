class Interpreter

  def initialize(code)
    @code = code
    @primitives = {}
  end
  
  def attach_primitive(name, &block)
    @primitives[name] = block
  end
  
  def run
    ast = Analyzer.analyze(Parser.parse(@code), @primitives.keys)
    if ast
      instructions = CodeGenerator.new(ast).generate
      vm = VM.new(instructions)
      vm.run
    else
      raise @parser.failure_reason
    end
  end

  def self.run(code)
    new(code).run
  end

end
