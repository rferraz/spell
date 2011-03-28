require "llvm/core"
require "llvm/execution_engine"
require "llvm/transforms/scalar"
require "llvm/dsl/dsl"

SPELL_EXTENSION = ".spell"

ORIGINAL_MAIN_METHOD_NAME = "main"
MAIN_METHOD_NAME = "spell.main"

INT_FLAG = 1
EXCEPTION_FLAG = 2
FLOAT_FLAG = 3
STRING_FLAG = 4
ARRAY_FLAG = 5
DICTIONARY_FLAG = 6
CONTEXT_FLAG = 7

PRIMITIVE_NEW_EXCEPTION = "spell.new.exception"
PRIMITIVE_NEW_FLOAT = "spell.new.float"
PRIMITIVE_NEW_STRING = "spell.new.string"
PRIMITIVE_NEW_ARRAY = "spell.new.array"
PRIMITIVE_NEW_DICTIONARY = "spell.new.dictionary"
PRIMITIVE_NEW_CONTEXT = "spell.new.context"

PRIMITIVE_CONCAT = "spell.concat"

PRIMITIVE_IS_STRING = "spell.is.string"
PRIMITIVE_IS_ARRAY = "spell.is.array"

PRIMITIVE_EQUALS = "spell.equals"
PRIMITIVE_NOT_EQUALS = "spell.not.equals"

PRIMITIVE_COMPARE_NUMERIC = "spell.compare.numeric"
PRIMITIVE_COMPARE_STRING = "spell.compare.string"

PRIMITIVE_PLUS = "spell.plus"
PRIMITIVE_MINUS = "spell.minus"
PRIMITIVE_TIMES = "spell.times"
PRIMITIVE_DIVIDE = "spell.divide"

PRIMITIVE_LESS_THAN = "spell.less.than"
PRIMITIVE_GREATER_THAN = "spell.greater.than"
PRIMITIVE_LESS_THAN_OR_EQUAL_TO = "spell.less.than.or.equal.to"
PRIMITIVE_GREATER_THAN_OR_EQUAL_TO = "spell.greater.than.or.equal.to"

PRIMITIVE_RAISE_EXCEPTION = "spell.raise.exception"

PRIMITIVE_ASSERT = "spell.assert"

PRIMITIVE_INT_TO_STRING = "spell.int.to.string"
PRIMITIVE_FLOAT_TO_STRING = "spell.float.to.string"

PRIMITIVE_TO_STRING = "spell.to.string"

PRIMITIVE_NOT = "spell.not"

PRIMITIVE_ARRAY_ACCESS = "spell.array.access"
PRIMITIVE_ARRAY_CONCAT = "spell.array.concat"
PRIMITIVE_ARRAY_CONS = "spell.array.cons"

PRIMITIVE_DICTIONARY_ACCESS = "spell.dictionary.access"

PRIMITIVE_LENGTH = "spell.length"
PRIMITIVE_HEAD = "spell.head"
PRIMITIVE_TAIL = "spell.tail"

PRIMITIVE_SPELL_APPLY_ROOT = "spell.apply."
PRIMITIVE_SPELL_APPLY_MAX_DIRECT_PARAMETERS = 8

PRIMITIVE_STACK_PARENT = "spell.stack.parent"

PRIMITIVE_HASH = "spell.hash"

MALLOC_TYPE = :int8

SPELL_VALUE = pointer_type(MALLOC_TYPE)

SPELL_STACK = recursive_type { |me| struct_type(pointer_type(me), :int, array_type(SPELL_VALUE, 0)) }

SPELL_STRING = struct_type(:int, :int, array_type(:int8, 0))
SPELL_EXCEPTION = struct_type(:int, pointer_type(SPELL_STRING))
SPELL_FLOAT = struct_type(:int, :float)
SPELL_ARRAY = struct_type(:int, :int, array_type(SPELL_VALUE, 0))
SPELL_DICTIONARY = struct_type(:int, :int, array_type(struct_type(SPELL_VALUE, SPELL_VALUE), 0))
SPELL_CONTEXT = struct_type(:int, pointer_type(SPELL_STACK), SPELL_VALUE, :int)

MEMORY_ROOT = "__root__"

def random_const_name
  random_name("const_")
end

def random_closure_name
  random_name("__anonymous__")
end

def random_name(root)
  base = rand.to_s
  root + base[2, base.length - 2]
end