require "treetop"

Treetop.load File.join(File.dirname(__FILE__), "spell", "spell.treetop")

require "spell/extensions/program"
require "spell/extensions/statement"
require "spell/extensions/pass"
require "spell/extensions/number_literal"
require "spell/extensions/string_literal"
require "spell/extensions/binary"
require "spell/extensions/primary"
require "spell/extensions/call"
require "spell/extensions/parenthesized_expression"
require "spell/extensions/do_expression"
require "spell/extensions/with_expression"
require "spell/extensions/assignment"
require "spell/extensions/guard"
require "spell/extensions/dictionary"

require "spell/ast/program"
require "spell/ast/statement"
require "spell/ast/pass"
require "spell/ast/literal"
require "spell/ast/invoke"
require "spell/ast/expression"
require "spell/ast/assignment"
require "spell/ast/case"
require "spell/ast/dictionary"


