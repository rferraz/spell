class LLVMPrimitivesBuilder
  
  class << self
    
    def build(builder)
      build_memory_primitives(builder)
      build_allocation_primitives(builder)
      build_numeric_primitives(builder)
    end

    protected
    
    def build_memory_primitives(builder)
      builder.external "malloc", [:int32], SPELL_VALUE
      builder.external "free", [SPELL_VALUE], :void
    end
    
    def build_allocation_primitives(builder)
      build_allocation_primitive(builder, :float)
    end
    
    def build_allocation_primitive(builder, type)
      builder.function [type], SPELL_VALUE, PRIMITIVE_NEW_FLOAT do |f|
        pointer = f.malloc(SIZE_INT * 2)
        f.store(flag_for(type), f.flag_pointer(pointer))
        f.store(f.arg(0), f.box_pointer(pointer, :float))
        f.returns(pointer)
      end
    end
    
    def build_numeric_primitives(builder)
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_PLUS do |f|
        f.entry {
          f.condition(f.icmp(:eq, f.and(f.and(f.as_int(f.arg(0)), f.as_int(f.arg(1))), int(1)), int(1)), :addint, :dofirst)
        }
        f.block(:addint) {
          f.returns(f.box_int(f.add(f.unbox_int(f.arg(0)), f.unbox_int(f.arg(1)))))
        }
        f.block(:dofirst) {
          f.condition(f.is_int(f.arg(0)), :p1int, :p1float)
        }
        f.block(:p1int) {
          f.set_bookmark(:p1a, f.ui2fp(f.unbox_int(f.arg(0)), type_by_name(:float)))
          f.branch(:dosecond)
        }
        f.block(:p1float) {
          f.set_bookmark(:p1b, f.unbox(f.arg(0), :float))
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
          f.set_bookmark(:p2b, f.unbox(f.arg(1), :float))
          f.branch(:addfloat)
        }
        f.block(:addfloat) {
          p2 = f.phi :float,
                { :on => f.get_bookmark(:p2a), :return_from => :p2int },
                { :on => f.get_bookmark(:p2b), :return_from => :p2float }
          f.returns(f.primitive_new_float(f.fadd(f.get_bookmark(:p1), p2)))
        }
      end
    end

    def flag_for(type)
      case type
      when :float
        int(FLOAT_FLAG)
      end
    end

  end
  
end