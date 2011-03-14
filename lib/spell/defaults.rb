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

PRIMITIVE_NEW_EXCEPTION = "spell.new.exception"
PRIMITIVE_NEW_FLOAT = "spell.new.float"
PRIMITIVE_NEW_STRING = "spell.new.string"

PRIMITIVE_CONCAT = "spell.concat"

PRIMITIVE_IS_STRING = "spell.is.string"

PRIMITIVE_EQUALS = "spell.equals"
PRIMITIVE_NOT_EQUALS = "spell.not.equals"

PRIMITIVE_PLUS = "spell.plus"
PRIMITIVE_MINUS = "spell.minus"
PRIMITIVE_TIMES = "spell.times"
PRIMITIVE_DIVIDE = "spell.divide"

PRIMITIVE_RAISE_EXCEPTION = "spell.raise.exception"

PRIMITIVE_ASSERT = "spell.assert"

PRIMITIVE_INT_TO_STRING = "spell.int.to.string"
PRIMITIVE_FLOAT_TO_STRING = "spell.float.to.string"

PRIMITIVE_TO_STRING = "spell.to.string"

PRIMITIVE_NOT = "spell.not"

MALLOC_TYPE = :int8

SPELL_VALUE = pointer_type(MALLOC_TYPE)

SPELL_STRING = struct_type(:int, :int, array_type(:int8, 0))
SPELL_EXCEPTION = struct_type(:int, pointer_type(SPELL_STRING))
SPELL_FLOAT = struct_type(:int, :float)

MEMORY_ROOT = "__root__"
