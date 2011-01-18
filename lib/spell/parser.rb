class Parser < Parslet::Parser

  root(:statements)

  rule(:statements) {
    extra_spaces >>
    (statement >> ((spaces? >> breaks >> spaces?).repeat(1) >> statement).repeat) >>
    extra_spaces
  }

  rule(:statement) { name >> arguments >> define >> body }

  rule(:name) { identifier }

  rule(:arguments) { spaces? >> str("(") >> str(")") >> spaces? }

  rule(:define) { spaces? >> str("=") >> spaces? }

  rule(:body) { expression }

  rule(:expression) { binary | primary | pass }

  rule(:binary) { (primary >> spaces? >> selector >> spaces? >> binary) | primary }

  rule(:primary) { variable | literal }

  rule(:variable) { identifier }

  rule(:literal) { number | string }

  rule(:number) { decimal | integer }

  rule(:decimal) { sign.maybe >> digits >> period >> digits }

  rule(:integer) { sign.maybe >> digits }

  rule(:string) { (quote >> (quote.absnt? >> any).repeat >> quote).repeat(1) }

  rule(:identifier) { identifier_part >> (identifier_separator >> identifier_part).repeat }

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

  rule(:pass) { str("pass") }

end
