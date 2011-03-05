class LLVMPrimitivesBuilder
  
  class << self
    
    def build(builder)
      build_memory_primitives(builder)
      build_allocation_primitives(builder)
      build_numeric_primitives(builder)
    end

    protected
    
    def build_memory_primitives(builder)
      builder.external "malloc", [:int], SPELL_VALUE
      builder.external "free", [SPELL_VALUE], :void
    end
    
    def build_allocation_primitives(builder)
      build_allocation_primitive(builder, :float)
      builder.function [SPELL_VALUE], SPELL_VALUE, UNBOX do |f|
        f.returns(f.gep(f.arg(0), int(1)))
      end
    end
    
    def build_allocation_primitive(builder, type)
      builder.function [type], SPELL_VALUE, NEW_FLOAT do |f|
        pointer = f.call("malloc", int(SIZE_INT + SIZE_FLOAT))
        ip = f.bit_cast(pointer, pointer_type(:int))
        fp = f.bit_cast(f.gep(pointer, int(1)), pointer_type(type))
        f.store(flag(type), ip)
        f.store(f.arg(0), fp)
        f.returns(pointer)
      end
    end
    
    def build_numeric_primitives(builder)
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, "primitive_plus" do |f|
        fv = f.load(f.bit_cast(f.gep(f.arg(0), int(1)), pointer_type(:float)))
        iv = f.ui2fp(f.lshr(f.arg(1), int(1)), type_by_name(:float))
        fpv = f.call(NEW_FLOAT, f.fadd(fv, iv))
        f.returns(fpv)
      end
    end

    def flag(type)
      case type
      when :float
        int(FLOAT_FLAG)
      end
    end

  end
  
end