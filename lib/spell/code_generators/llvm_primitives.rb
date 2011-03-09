class LLVMPrimitivesBuilder
  
  class << self
    
    def build(builder)
      builder_exception_primitives(builder)
      build_memory_primitives(builder)
      build_allocation_primitives(builder)
      build_numeric_primitives(builder)
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
      builder.external :memcpy, [pointer_type(:int8), pointer_type(:int8), :int], pointer_type(:int8)
      builder.external :setjmp, [pointer_type(:int8)], :int32
      builder.external :longjmp, [pointer_type(:int8), :int32], :void
      builder.global :jmpenv, [:int8] * 256 do
        LLVM::ConstantArray.const(LLVM::Int, 256) { |i| LLVM::Int(0) }
      end
      builder.global :exception, SPELL_EXCEPTION do
        builder.constant("")
      end
      builder.function [pointer_type(SPELL_EXCEPTION)], :void, PRIMITIVE_RAISE do |f|
        f.store(f.load(f.arg(0)), builder.get_global(:exception))
        f.call(:longjmp, f.gep(builder.get_global(:jmpenv), int(0), int(0)), int(1, :size => 32))
        f.unreachable
      end
    end
    
    def build_memory_primitives(builder)
      builder.external "memcpy", [pointer_type(:int8), pointer_type(:int8), :int, :int32], pointer_type(:int8)
      builder.external "llvm.memset.i64", [pointer_type(:int8), :int8, :int, :int32], :void
      builder.external "malloc", [:int32], SPELL_VALUE
      builder.external "free", [SPELL_VALUE], :void
    end
    
    def build_allocation_primitives(builder)
      build_allocation_primitive(builder, :float)
      builder.function [SPELL_VALUE], SPELL_VALUE, PRIMITIVE_NEW_EXCEPTION do |f|
        pointer = f.malloc(SPELL_EXCEPTION)
        f.store(f.flag_for(:exception), f.flag_pointer(pointer))
        f.store(f.cast(f.arg(0), pointer_type(:int8)), f.box_pointer(pointer))
        f.returns(f.cast(pointer, SPELL_VALUE))
      end
      builder.function [SPELL_VALUE, :int], SPELL_VALUE, PRIMITIVE_NEW_STRING do |f|
        string_pointer = f.malloc_on_size(f.arg(1))
        f.call("memcpy", string_pointer, f.arg(0), f.arg(1), int(0, :size => 32))
        pointer = f.malloc(SPELL_STRING)
        f.store(f.flag_for(:string), f.flag_pointer(pointer))
        f.store(f.cast(string_pointer, pointer_type(:int8)), f.box_pointer(pointer))
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
    
    def build_numeric_primitives(builder)
      build_numeric_primitive(builder, PRIMITIVE_PLUS, :add, :fadd)
      build_numeric_primitive(builder, PRIMITIVE_MINUS, :sub, :fsub)
      build_numeric_primitive(builder, PRIMITIVE_TIMES, :mul, :fmul)
      build_numeric_primitive(builder, PRIMITIVE_DIVIDE, :udiv, :fdiv)
    end
    
    def build_numeric_primitive(builder, name, int_operator, float_operator)
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, name do |f|
        f.entry {
          f.condition(f.icmp(:eq, f.and(f.and(f.as_int(f.arg(0)), f.as_int(f.arg(1))), int(1)), int(1)), :addint, :dofirst)
        }
        f.block(:addint) {
          f.returns(f.box_int(f.send(int_operator, f.unbox_int(f.arg(0)), f.unbox_int(f.arg(1)))))
        }
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

  end
  
end