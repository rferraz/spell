require "llvm/core"
require "llvm/execution_engine"
require "llvm/transforms/scalar"
require "llvm/dsl/dsl"

SPELL_EXTENSION = ".spell"

ORIGINAL_MAIN_METHOD_NAME = "main"
MAIN_METHOD_NAME = "spell.main"

INT_FLAG = 1
FLOAT_FLAG = 3

PRIMITIVE_NEW_FLOAT = "spell.new.float"

PRIMITIVE_PLUS = "spell.plus"

SIZE_INT = [1.to_i].pack("l!").size
SIZE_FLOAT = [1.to_f].pack("f").size

MALLOC_TYPE = :int8

SPELL_VALUE = pointer_type(MALLOC_TYPE)

MEMORY_ROOT = "__root__"
