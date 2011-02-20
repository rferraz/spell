# In the absence of an extension mechanism in
# Treetop, we use this hack to create a global
# root path for import statement
class Treetop::Runtime::SyntaxNode
  class << self; attr_accessor :spell_root_paths;  end
end

class Parser

  def initialize(*root_paths)
    # Encapsulates the Treetop generated parser and
    # provides an already pre-processed AST
    @internal_parser = SpellParser.new
    Treetop::Runtime::SyntaxNode.spell_root_paths = root_paths
  end

  def parse(code)
    raw_ast = @internal_parser.parse(code)
    if raw_ast
      raw_ast.build
    else
      raise SpellParserError.new(@internal_parser.failure_reason)
    end
  end

  def self.parse(code, root_path = ".")
    new(root_path).parse(code)
  end

end
