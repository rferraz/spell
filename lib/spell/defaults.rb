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

PRIMITIVE_NEW_EXCEPTION = "spell.new.exception"
PRIMITIVE_NEW_FLOAT = "spell.new.float"
PRIMITIVE_NEW_STRING = "spell.new.string"
PRIMITIVE_NEW_ARRAY = "spell.new.array"

PRIMITIVE_CONCAT = "spell.concat"

PRIMITIVE_IS_STRING = "spell.is.string"

PRIMITIVE_EQUALS = "spell.equals"
PRIMITIVE_NOT_EQUALS = "spell.not.equals"

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

MALLOC_TYPE = :int8

SPELL_VALUE = pointer_type(MALLOC_TYPE)

SPELL_STRING = struct_type(:int, :int, array_type(:int8, 0))
SPELL_EXCEPTION = struct_type(:int, pointer_type(SPELL_STRING))
SPELL_FLOAT = struct_type(:int, :float)
SPELL_ARRAY = struct_type(:int, :int, array_type(SPELL_VALUE, 0))

MEMORY_ROOT = "__root__"
