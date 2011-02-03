class Interpreter

  def initialize
    @parser = SpellParser.new
  end

  def run(code)
    ast = @parser.parse(code)
    if ast
      instructions = CodeGenerator.new(ast.build).generate
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
