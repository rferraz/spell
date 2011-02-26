# In the absence of an extension mechanism in
# Treetop, we use this hack to create a global
# root path for import statement
class Treetop::Runtime::SyntaxNode
  class << self
    attr_accessor :spell_root_paths
    attr_accessor :import_parser
  end
end

class Parser

  def initialize(*root_paths)
    Treetop::Runtime::SyntaxNode.spell_root_paths = root_paths
    Treetop::Runtime::SyntaxNode.import_parser = self
  end

  def run(code)
    parser = SpellParser.new
    raw_ast = parser.parse(code)
    if raw_ast
      raw_ast.build
    else
      raise SpellParserError.new(parser.failure_reason)
    end
  end

end