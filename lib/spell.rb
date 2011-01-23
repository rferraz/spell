require "treetop"

Treetop.load File.join(File.dirname(__FILE__), "spell", "spell.treetop")

require "spell/extensions/program"
require "spell/extensions/statement"
require "spell/extensions/pass"
require "spell/extensions/number_literal"
require "spell/extensions/string_literal"

require "spell/ast/program"
require "spell/ast/statement"
require "spell/ast/pass"
require "spell/ast/literal"


