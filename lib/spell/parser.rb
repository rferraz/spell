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

  rule(:body) { str("pass") }

  rule(:identifier) { identifier_part >> (identifier_separator >> identifier_part).repeat }

  rule(:identifier_separator) { str("#") }

  rule(:identifier_part) { letter >> alpha.repeat }

  rule(:alpha) { letter | digit }

  rule(:letter) { match["a-zA-Z"] }

  rule(:digit) { match["0-9"] }

  rule(:breaks?) { breaks.maybe }
  rule(:breaks) { match["\\r\\n"].repeat(1) }

  rule(:spaces?) { spaces.maybe }
  rule(:spaces) { match[" \t"].repeat(1) }

  rule(:extra_spaces) { match["\\r\\n\\s"].repeat }

end
