class Parser < Parslet::Parser

  root(:statements)

  rule(:statements) {
    extra_spaces >>
    (statement >> (line_breaks.maybe >> statement).repeat) >>
    extra_spaces
  }

  rule(:statement) { definition >> body }

  rule(:definition) { name >> arguments >> define }

  rule(:name) { identifier }

  rule(:arguments) { spaces? >> str("(") >> str(")") >> spaces? }

  rule(:define) { spaces? >> str("=") >> spaces? }

  rule(:body) {
    (do_expression >> with.maybe) |
    (expression >> (line_breaks >> with).maybe)
  }

  rule(:do_expression) {
    line_breaks >> str("do") >> line_breaks >>
    (expression >> line_breaks).repeat(1)
  }

  rule(:expression) { binary | primary | pass }

  rule(:with) {
    str("with") >> line_breaks >>
    (expression >> line_breaks).repeat(1)
  }

  rule(:call) { identifier >> (spaces >> binary).repeat }

  rule(:binary) { (primary >> spaces? >> selector >> spaces? >> binary) | primary }

  rule(:primary) { (str("(") >> expression >> str(")")) | call | variable | literal }

  rule(:variable) { identifier }

  rule(:literal) { number | string }

  rule(:number) { decimal | integer }

  rule(:decimal) { sign.maybe >> digits >> period >> digits }

  rule(:integer) { sign.maybe >> digits }

  rule(:string) { (quote >> (quote.absnt? >> any).repeat >> quote).repeat(1) }

  rule(:identifier) { (str("with") | str("do")).absnt? >> identifier_part >> (identifier_separator >> identifier_part).repeat }

  rule(:identifier_separator) { str("#") }

  rule(:identifier_part) { letter >> alpha.repeat }

  rule(:selector) { match["+*-/\\\\~:<>=@%&?!,^"].repeat(1) }

  rule(:alpha) { letter | digit }

  rule(:letter) { match["a-zA-Z"] }

  rule(:sign) { str("-") }

  rule(:period) { str(".") }

  rule(:quote) { str("\"") }

  rule(:digits) { digit.repeat(1) }

  rule(:digit) { match["0-9"] }

  rule(:breaks?) { breaks.maybe }
  rule(:breaks) { match["\\r\\n"].repeat(1) }

  rule(:spaces?) { spaces.maybe }
  rule(:spaces) { match[" \t"].repeat(1) }

  rule(:extra_spaces) { match["\\r\\n\\s"].repeat }

  rule(:line_breaks) { (spaces? >> breaks >> spaces?).repeat(1) }

  rule(:pass) { str("pass") }

end
