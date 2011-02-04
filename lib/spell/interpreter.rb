class Interpreter

  def run(code)
    ast = Parser.parse(code)
    if ast
      instructions = CodeGenerator.new(ast).generate
      vm = VM.new(instructions)
      vm.run
    else
      raise @parser.failure_reason
    end
  end

  def self.run(code)
    new.run(code)
  end

end
