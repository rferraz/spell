$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

begin
  require "ruby-debug"
rescue LoadError
  # Ignore ruby-debug is case it's not installed
end

require "test/unit"

require "spell"

def sexp_to_string(sexp)
  case sexp
  when Array
    "[" + sexp.inject([]) { |memo, element| memo << sexp_to_string(element) ; memo }.join(", ") + "]"
  when String
    sexp
  when Symbol
    ":" + sexp.to_s
  else
    ""
  end
end
