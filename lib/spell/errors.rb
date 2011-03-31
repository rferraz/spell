class SpellError < RuntimeError; end
class SpellParserError < SpellError; end
class SpellAnalyzerError < SpellError; end
class SpellUnrelatedScopeError < SpellError; end
class SpellInvalidMethodCallError < SpellError; end
class SpellInvalidBytecodeError < SpellError; end
class SpellInvalidPrimitiveError < SpellError; end
class SpellArgumentMistatch < SpellError; end

