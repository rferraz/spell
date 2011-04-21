require "llvm"
require "llvm-dsl"

require "treetop"

Treetop.load File.join(File.dirname(__FILE__), "spell", "parser", "spell.treetop")

require "spell/defaults"
require "spell/extensions"
require "spell/errors"

require "spell/pass_manager"

require "spell/parser/parser"

require "spell/extensions/parser_extension"
require "spell/extensions/program"
require "spell/extensions/statement"
require "spell/extensions/pass"
require "spell/extensions/number_literal"
require "spell/extensions/string_literal"
require "spell/extensions/boolean_literal"
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
require "spell/ast/method"
require "spell/ast/load"
require "spell/ast/store"
require "spell/ast/closure"
require "spell/ast/up"

require "spell/bytecode/dumper"
require "spell/bytecode/loader"
require "spell/bytecode/storable"

require "spell/bytecode/invoke"
require "spell/bytecode/label"
require "spell/bytecode/load"
require "spell/bytecode/store"
require "spell/bytecode/push"
require "spell/bytecode/return"
require "spell/bytecode/jump"
require "spell/bytecode/dictionary"
require "spell/bytecode/array"
require "spell/bytecode/pass"
require "spell/bytecode/closure"

require "spell/analyzer/analyzer"
require "spell/analyzer/scope"
require "spell/analyzer/symbol_table"

require "spell/code_generators/bytecode/bytecode_generator"
require "spell/code_generators/llvm/llvm_code_generator"

require "spell/llvm_support/llvm_config"
require "spell/llvm_support/llvm_helpers"
require "spell/llvm_support/llvm_primitives"
require "spell/llvm_support/llvm_runner"
require "spell/llvm_support/llvm_compiler"

require "spell/interpreter/interpreter"
require "spell/interpreter/vm"
require "spell/interpreter/frame"
require "spell/interpreter/closure_context"

require "spell/compiler/compiler"

require "spell/prelude"
