class Parser

  def initialize
    # Encapsulates the Treetop generated parser and
    # provides an already pre-processed AST
    @internal_parser = SpellParser.new
  end

  def parse(code)
    raw_ast = @internal_parser.parse(code)
    if raw_ast
      raw_ast.build
    else
      raise SpellParserError.new(@internal_parser.failure_reason)
    end
  end

  def self.parse(code)
    new.parse(code)
  end

end
