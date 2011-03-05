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
      builder.function [SPELL_VALUE], SPELL_VALUE, PRIMITIVE_UNBOX do |f|
        f.returns(f.gep(f.arg(0), int(1)))
      end
    end
    
    def build_allocation_primitive(builder, type)
      builder.function [type], SPELL_VALUE, PRIMITIVE_NEW_FLOAT do |f|
        pointer = f.malloc(SIZE_INT + SIZE_FLOAT)
        f.store(flag_of(type), f.get_flag(pointer))
        f.store(f.arg(0), f.get_box(pointer, :float))
        f.returns(pointer)
      end
    end
    
    def build_numeric_primitives(builder)
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_PLUS do |f|
        fv = f.unbox(f.arg(0), :float)
        iv = f.ui2fp(f.unbox_int(f.arg(1)), type_by_name(:float))
        fpv = f.new_float(f.fadd(fv, iv))
        f.returns(fpv)
      end
    end

    def flag_of(type)
      case type
      when :float
        int(FLOAT_FLAG)
      end
    end

  end
  
end