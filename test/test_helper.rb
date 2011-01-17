$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

begin
  require "ruby-debug"
rescue LoadError
  # Ignore ruby-debug is case it's not installed
end

require "test/unit"

require "spell"
