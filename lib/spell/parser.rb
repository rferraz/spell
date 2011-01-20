class Parser < Parslet::Parser

  root(:statements)

  rule(:statements) {
    extra_spaces >>
    (statement >> (line_breaks.repeat(2) >> statement).repeat) >>
    extra_spaces
  }

  rule(:statement) { definition >> body }

  rule(:definition) { name >> arguments >> define }

  rule(:name) { identifier }

  rule(:arguments) { spaces? >> str("(") >> argument_list.maybe >> str(")") >> spaces? }

  rule(:argument_list) {
    argument >> (spaces? >> comma >> spaces? >> argument).repeat
  }

  rule(:argument) { identifier }

  rule(:define) { spaces? >> str("=") >> spaces? }

  rule(:body) {
    (guard_expressions | do_expression | expression) >>
    (line_breaks >> with).maybe
  }

  rule(:guard_expressions) {
    (line_breaks >> guard).repeat(1)
  }

  rule(:guard) {
    str("?") >> spaces >>
    (default | expression) >> spaces >>
    str("=>") >> spaces >>
    expression
  }

  rule(:default) { str("_") }

  rule(:do_expression) {
    line_breaks >> str("do") >>
    (block_do | simple_do)
  }

  rule(:simple_do) { (line_breaks >> expression).repeat(1) }

  rule(:block_do) {
    extra_spaces? >>
    str("{") >>
    extra_spaces? >>
    expression >> (line_breaks >> expression).repeat >>
    extra_spaces? >>
    str("}") >>
    spaces?
  }

  rule(:expression) { binary | primary | pass }

  rule(:with) {
    str("with") >>
    (block_with | simple_with)
  }

  rule(:simple_with) { (line_breaks >> (statement | expression)).repeat(1) }

  rule(:block_with) {
    extra_spaces? >>
    str("{") >>
    extra_spaces? >>
    (statement | expression) >>
    (line_breaks >> (statement | expression)).repeat >>
    extra_spaces? >>
    str("}") >>
    spaces?
  }

  rule(:binary) { (primary >> spaces? >> selector >> spaces? >> binary) | primary }

  rule(:primary) { (str("(") >> expression >> str(")")) | dictionary_access | array_access | call | variable | literal }

  rule(:dictionary_access) { identifier >> (period >> identifier).repeat(1) }

  rule(:array_access) { identifier >> array_index.repeat(1) }

  rule(:array_index) { str("[") >> integer >> str("]") }

  rule(:variable) { identifier }

  rule(:call) { identifier >> (spaces >> binary).repeat }

  rule(:literal) { array | dictionary | number | string }

  rule(:array) {
    str("[") >>
    extra_spaces? >>
    (expression >> (extra_spaces >> expression).repeat).maybe >>
    extra_spaces? >>
    str("]")
  }

  rule(:dictionary) {
    str("{") >>
    extra_spaces? >>
    (dictionary_item >> (extra_spaces? >> semicolon >> extra_spaces? >> dictionary_item >> extra_spaces?).repeat).maybe >>
    extra_spaces? >>
    str("}")
  }

  rule(:dictionary_item) {
    extra_spaces?
    identifier >>
    colon >>
    extra_spaces?
    expression >>
    extra_spaces?
  }

  rule(:number) { decimal | integer }

  rule(:decimal) { sign.maybe >> digits >> period >> digits }

  rule(:integer) { sign.maybe >> digits }

  rule(:string) { (quote >> (quote.absnt? >> any).repeat >> quote).repeat(1) }

  rule(:identifier) {
    (str("with") | str("do")).absnt? >>
    identifier_part >> (identifier_separator >> identifier_part).repeat >>
    (single_quote).repeat
  }

  rule(:identifier_separator) { str("#") }

  rule(:identifier_part) { letter >> alpha.repeat }

  rule(:selector) {
    str("=>").absnt? >> str(".").absnt? >>
    match["+*-/\\\\~:<>=@%&?!,^"].repeat(1)
  }

  rule(:alpha) { letter | digit }

  rule(:letter) { match["a-zA-Z"] }

  rule(:sign) { str("-") }

  rule(:period) { str(".") }

  rule(:comma) { str(",") }

  rule(:colon) { str(":") }

  rule(:semicolon) { str(";") }

  rule(:quote) { str("\"") }

  rule(:single_quote) { str("'") }

  rule(:digits) { digit.repeat(1) }

  rule(:digit) { match["0-9"] }

  rule(:breaks?) { breaks.maybe }

  rule(:breaks) { match["\\r\\n"] }

  rule(:spaces?) { spaces.maybe }

  rule(:spaces) {
    match[" \t"].repeat >>
    (str("#") >> (breaks.absnt? >> any).repeat >> breaks.prsnt?).maybe
  }

  rule(:extra_spaces?) { extra_spaces.maybe }
  rule(:extra_spaces) { match["\\r\\n\\s"].repeat }

  rule(:line_breaks) { spaces? >> breaks >> spaces? }

  rule(:pass) { str("pass") }

end
