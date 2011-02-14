require "treetop"

Treetop.load File.join(File.dirname(__FILE__), "spell", "spell.treetop")

require "spell/defaults"
require "spell/extensions"
require "spell/errors"
require "spell/parser"

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
require "spell/extensions/array"
require "spell/extensions/block"
require "spell/extensions/primitive"
require "spell/extensions/import"

require "spell/ast/program"
require "spell/ast/statement"
require "spell/ast/pass"
require "spell/ast/literal"
require "spell/ast/invoke"
require "spell/ast/expression"
require "spell/ast/assignment"
require "spell/ast/case"
require "spell/ast/dictionary"
require "spell/ast/array"
require "spell/ast/block"
require "spell/ast/primitive"
require "spell/ast/return"
require "spell/ast/method"
require "spell/ast/load"
require "spell/ast/store"
require "spell/ast/closure"
require "spell/ast/up"

require "spell/analyzer/analyzer"
require "spell/analyzer/scope"
require "spell/analyzer/symbol_table"

require "spell/interpreter"
require "spell/code_generator"
require "spell/vm"
