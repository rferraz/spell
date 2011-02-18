$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

begin
  require "ruby-debug"
rescue LoadError
  # Ignore ruby-debug is case it's not installed
end

require "test/unit"

require "spell"

SPELL_EXTENSION = ".spell"
AST_EXTENSION = ".ast"

def sexp_to_string(sexp)
  case sexp
  when Array
    "(" + sexp.inject([]) { |memo, element| memo << sexp_to_string(element) ; memo }.join(" ") + ")"
  when Symbol
    sexp.to_s
  else
    sexp
  end
end

def cleanup_sexp(sexp)
  sexp.
    strip.
    gsub(/\r|\n/, "").
    gsub(/\s+/, " ").
    gsub("\\\"", "")
end

def assert_raise_with_message(exception, message, &block)
  assert_equal(message, assert_raises(exception, &block).message)
end
