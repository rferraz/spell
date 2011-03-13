class LLVMPrimitivesBuilder
  
  class << self
    
    def build(builder)
      builder_exception_primitives(builder)
      build_memory_primitives(builder)
      build_allocation_primitives(builder)
      build_string_primitives(builder)
      build_numeric_primitives(builder)
      build_equality_primitives(builder)
      build_assertion_primitives(builder)
      build_conversion_primitives(builder)
    end

    def build_main(builder)
      builder.function [], pointer_type(MALLOC_TYPE), ORIGINAL_MAIN_METHOD_NAME do |f|
        f.entry {
          setjmp = f.call(:setjmp, f.gep(builder.get_global(:jmpenv), int(0), int(0)))
          f.set_bookmark(:setjmp, setjmp)
          f.condition(f.icmp(:eq, int(0, :size => 32), setjmp), :normal, :exception)
        }
        f.block(:normal) {
          f.returns(f.call(MAIN_METHOD_NAME))
        }
        f.block(:exception) {
          f.returns(f.cast(builder.get_global(:exception), pointer_type(:int8)))
        }
      end
    end
    
    protected
    
    def builder_exception_primitives(builder)
      builder.external :setjmp, [pointer_type(:int8)], :int32
      builder.external :longjmp, [pointer_type(:int8), :int32], :void
      builder.global :jmpenv, [:int8] * 256 do
        LLVM::ConstantArray.const(LLVM::Int, 256) { |i| LLVM::Int(0) }
      end
      builder.global :exception, SPELL_EXCEPTION do
        builder.constant("")
      end
      builder.function [SPELL_VALUE], :void, PRIMITIVE_RAISE do |f|
        f.store(f.load(f.cast(f.arg(0), pointer_type(SPELL_EXCEPTION))), builder.get_global(:exception))
        f.call(:longjmp, f.gep(builder.get_global(:jmpenv), int(0), int(0)), int(1, :size => 32))
        f.unreachable
      end
    end
    
    def build_memory_primitives(builder)
      builder.external "memcmp", [pointer_type(:int8), pointer_type(:int8), :int], :int
      builder.external "memcpy", [pointer_type(:int8), pointer_type(:int8), :int], pointer_type(:int8)
      builder.external "memset", [pointer_type(:int8), :int, :int], pointer_type(:int8)
      builder.external "malloc", [:int32], SPELL_VALUE
      builder.external "free", [SPELL_VALUE], :void
    end
    
    def build_allocation_primitives(builder)
      build_allocation_primitive(builder, :float)
      builder.function [SPELL_VALUE], SPELL_VALUE, PRIMITIVE_NEW_EXCEPTION do |f|
        pointer = f.malloc(SPELL_EXCEPTION)
        f.store(f.flag_for(:exception), f.flag_pointer(pointer))
        f.store(f.cast(f.arg(0), pointer_type(SPELL_STRING)), f.box_pointer(pointer))
        f.returns(f.cast(pointer, SPELL_VALUE))
      end
      builder.function [SPELL_VALUE, :int], SPELL_VALUE, PRIMITIVE_NEW_STRING do |f|
        string_pointer = f.malloc_on_size(f.arg(1))
        f.call("memcpy", string_pointer, f.arg(0), f.arg(1))
        pointer = f.malloc(SPELL_STRING)
        f.store(f.flag_for(:string), f.flag_pointer(pointer))
        f.store(f.cast(string_pointer, pointer_type(:int8)), f.box_pointer(pointer))
        f.store(f.sub(f.arg(1), int(1)), f.length_pointer(pointer))
        f.returns(f.cast(pointer, SPELL_VALUE))
      end
    end    
    
    def build_allocation_primitive(builder, type)
      builder.function [type], SPELL_VALUE, PRIMITIVE_NEW_FLOAT do |f|
        pointer = f.malloc(SPELL_FLOAT)
        f.store(f.flag_for(type), f.flag_pointer(pointer))
        f.store(f.arg(0), f.box_pointer(pointer))
        f.returns(f.cast(pointer, SPELL_VALUE))
      end
    end
    
    def build_equality_primitives(builder)
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_EQUALS do |f|
        f.entry {
          f.condition(f.icmp(:eq, f.and(f.and(f.as_int(f.arg(0)), f.as_int(f.arg(1))), int(1)), int(1)), :int, :other)
        }
        f.block(:int) {
          result = f.icmp(:eq, f.as_int(f.arg(0)), f.as_int(f.arg(1)))
          f.returns(f.box_int(f.zext(result, type_by_name(:int))))
        }
        f.block(:other) {
          f.switch f.type_of(f.arg(0)), :exception,
            { :on => f.flag_for(:float), :go_to => :float },
            { :on => f.flag_for(:string), :go_to => :string }
        }
        f.block(:float) {
          f.condition(f.is_int(f.arg(1)), :p1int, :p1float)
        }
        f.block(:p1int) {
          f.set_bookmark(:p1a, f.ui2fp(f.unbox_int(f.arg(1)), type_by_name(:float)))
          f.branch(:floatcompare)
        }
        f.block(:p1float) {
          f.set_bookmark(:p1b, f.unbox(f.arg(1), SPELL_FLOAT))
          f.branch(:floatcompare)
        }
        f.block(:floatcompare) {
          p1 = f.phi :float,
                 { :on => f.get_bookmark(:p1a), :return_from => :p1int },
                 { :on => f.get_bookmark(:p1b), :return_from => :p1float }
          result = f.fcmp(:ueq, f.unbox(f.arg(0), SPELL_FLOAT), p1)
          f.returns(f.box_int(f.zext(result, type_by_name(:int))))
        }
        f.block(:string) {
          f.condition(f.icmp(:eq, f.type_of(f.arg(1)), f.flag_for(:string)), :bothstrings, :exception)
        }
        f.block(:bothstrings) {
          length1 = f.load(f.length_pointer(f.arg(0)))
          length2 = f.load(f.length_pointer(f.arg(1)))
          f.condition(f.icmp(:eq, length1, length2), :memcmp, :unequalstrings)
        }
        f.block(:memcmp) {
          memcmp = f.call(:memcmp, f.unbox(f.arg(0), SPELL_STRING), f.unbox(f.arg(1), SPELL_STRING), f.load(f.length_pointer(f.arg(0))))
          f.condition(f.icmp(:eq, memcmp, int(0)), :equalstrings, :unequalstrings)
        }
        f.block(:equalstrings) {
          f.returns(f.box_int(f.zext(int(1), type_by_name(:int))))
        }
        f.block(:unequalstrings) {
          f.returns(f.box_int(f.zext(int(0), type_by_name(:int))))
        }        
        f.block(:exception) {
          # FIX: display operands
          f.primitive_raise(f.allocate_string("Invalid comparison"))
          f.unreachable
        }
      end
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_NOT_EQUALS do |f|
        f.returns(f.box_int(f.sub(int(1), f.unbox_int(f.call(PRIMITIVE_EQUALS, f.arg(0), f.arg(1))))))
      end
    end
    
    def build_assertion_primitives(builder)
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_ASSERT do |f|
        f.entry {
          f.condition(f.icmp(:eq, f.unbox_int(f.arg(0)), int(1)), :ok, :notok)
        }
        f.block(:ok) {
          f.returns(f.arg(0))
        }
        f.block(:notok) {
          f.primitive_raise(f.arg(1))
          f.unreachable
        }
      end
    end
    
    def build_string_primitives(builder)
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_CONCAT do |f|
        f.entry {
          f.condition(f.icmp(:eq, f.type_of(f.arg(1)), f.flag_for(:string)), :bothstrings, :exception)
        }
        f.block(:bothstrings) {
          length1 = f.load(f.length_pointer(f.arg(0)))
          length2 = f.load(f.length_pointer(f.arg(1)))
          string_pointer = f.malloc_on_size(f.sub(f.add(length1, length2), int(1)))
          f.call("memcpy", string_pointer, f.unbox(f.arg(0), SPELL_STRING), length1)
          f.call("memcpy", f.gep(string_pointer, length1), f.unbox(f.arg(1), SPELL_STRING), f.add(length2, int(1)))
          pointer = f.malloc(SPELL_STRING)
          f.store(f.flag_for(:string), f.flag_pointer(pointer))
          f.store(f.cast(string_pointer, pointer_type(:int8)), f.box_pointer(pointer))
          f.store(f.add(length1, length2), f.length_pointer(pointer))
          f.returns(f.cast(pointer, SPELL_VALUE))
        }
        f.block(:exception) {
          # FIX: display operands
          f.primitive_raise(f.allocate_string("Can't compare string to non-string"))
          f.unreachable
        }
      end
    end
    
    def build_numeric_primitives(builder)
      build_numeric_primitive(builder, PRIMITIVE_PLUS, :add, :fadd)
      build_numeric_primitive(builder, PRIMITIVE_MINUS, :sub, :fsub)
      build_numeric_primitive(builder, PRIMITIVE_TIMES, :mul, :fmul)
      build_numeric_primitive(builder, PRIMITIVE_DIVIDE, :udiv, :fdiv)
    end
    
    def build_numeric_primitive(builder, name, int_operator, float_operator)
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, name do |f|
        f.entry {
          f.condition(f.icmp(:eq, f.and(f.and(f.as_int(f.arg(0)), f.as_int(f.arg(1))), int(1)), int(1)), :addint, :other)
        }
        f.block(:addint) {
          f.returns(f.box_int(f.send(int_operator, f.unbox_int(f.arg(0)), f.unbox_int(f.arg(1)))))
        }
        f.block(:other) {
          # Fix: find a better way to do that
          if name == PRIMITIVE_PLUS
            f.condition(f.is_not_int(f.arg(0)), :possiblestring, :dofirst)
          else
            f.branch(:dofirst)
          end
        }
        # Fix: find a better way to do that
        if name == PRIMITIVE_PLUS
          f.block(:possiblestring) {
            f.condition(f.icmp(:eq, f.type_of(f.arg(0)), f.flag_for(:string)), :string, :dofirst)            
          }
          f.block(:string) {
            f.returns(f.primitive_concat(f.arg(0), f.arg(1)))
          }
        end
        f.block(:dofirst) {
          f.condition(f.is_int(f.arg(0)), :p1int, :p1float)
        }
        f.block(:p1int) {
          f.set_bookmark(:p1a, f.ui2fp(f.unbox_int(f.arg(0)), type_by_name(:float)))
          f.branch(:dosecond)
        }
        f.block(:p1float) {
          f.set_bookmark(:p1b, f.unbox(f.arg(0), SPELL_FLOAT))
          f.branch(:dosecond)
        }
        f.block(:dosecond) {
          p1 = f.phi :float,
                 { :on => f.get_bookmark(:p1a), :return_from => :p1int },
                 { :on => f.get_bookmark(:p1b), :return_from => :p1float }
          f.set_bookmark(:p1, p1)
          f.condition(f.is_int(f.arg(1)), :p2int, :p2float)
        }
        f.block(:p2int) {
          f.set_bookmark(:p2a, f.ui2fp(f.unbox_int(f.arg(1)), type_by_name(:float)))
          f.branch(:addfloat)
        }
        f.block(:p2float) {
          f.set_bookmark(:p2b, f.unbox(f.arg(1), SPELL_FLOAT))
          f.branch(:addfloat)
        }
        f.block(:addfloat) {
          p2 = f.phi :float,
                { :on => f.get_bookmark(:p2a), :return_from => :p2int },
                { :on => f.get_bookmark(:p2b), :return_from => :p2float }
          f.returns(f.primitive_new_float(f.send(float_operator, f.get_bookmark(:p1), p2)))
        }
      end
    end
    
    def build_conversion_primitives(builder)
      builder.external "sprintf", [SPELL_VALUE, SPELL_VALUE], :int32, :varargs => true
      builder.function [SPELL_VALUE], SPELL_VALUE, PRIMITIVE_INT_TO_STRING do |f|
        pointer = f.malloc_on_size(int(16, :size => 32))
        f.call("memset", pointer, int(0), int(16))
        size = f.call("sprintf", pointer, f.string_constant("%d"), f.unbox_int(f.arg(0)))
        f.returns(f.cast(f.primitive_new_string(pointer, f.add(f.zext(size, type_by_name(:int)), int(1))), SPELL_VALUE))
      end
      builder.function [SPELL_VALUE], SPELL_VALUE, PRIMITIVE_FLOAT_TO_STRING do |f|
        pointer = f.malloc_on_size(int(32, :size => 32))
        f.call("memset", pointer, int(0), int(32))
        size = f.call("sprintf", pointer, f.string_constant("%g"), f.fp_ext(f.unbox(f.arg(0), SPELL_FLOAT), type_by_name(:double)))
        f.returns(f.cast(f.primitive_new_string(pointer, f.add(f.zext(size, type_by_name(:int)), int(1))), SPELL_VALUE))
      end
      builder.function [SPELL_VALUE], SPELL_VALUE, PRIMITIVE_TO_STRING do |f|
        f.entry {
          f.condition(f.is_int(f.arg(0)), :int, :other)
        }
        f.block(:int) {
          f.returns(f.call(PRIMITIVE_INT_TO_STRING, f.arg(0)))
        }
        f.block(:other) {
          f.switch f.type_of(f.arg(0)), :exception,
            { :on => f.flag_for(:float), :go_to => :float },
            { :on => f.flag_for(:string), :go_to => :string }
        }
        f.block(:float) {
          f.returns(f.call(PRIMITIVE_FLOAT_TO_STRING, f.arg(0)))
        }
        f.block(:string) {
          f.returns(f.arg(0))
        }
        f.block(:exception) {
          f.primitive_raise(f.allocate_string("Unknown type"))
          f.unreachable
        }
      end
    end   
    
  end
  
end