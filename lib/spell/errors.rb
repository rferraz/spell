class SpellError < RuntimeError; end
class SpellParserError < SpellError; end
class SpellAnalyzerError < SpellError; end
class SpellUnrelatedScopeError < SpellError; end

