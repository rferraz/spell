class LLVMPrimitivesBuilder
  
  class << self
    
    def build(builder)
      build_stack_primitives(builder)
      build_exception_primitives(builder)
      build_memory_primitives(builder)
      build_allocation_primitives(builder)
      build_string_primitives(builder)
      build_numeric_primitives(builder)
      build_equality_primitives(builder)
      build_assertion_primitives(builder)
      build_conversion_primitives(builder)
      build_comparison_primitives(builder)
      build_array_primitives(builder)
      build_dictionary_primitives(builder)
      build_closure_primitives(builder)
      build_variable_primitives(builder)
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
    
    def build_stack_primitives(builder)
      builder.global :stack, pointer_type(SPELL_STACK) do
        pointer_type(SPELL_STACK).null_pointer
      end
      builder.function [pointer_type(SPELL_STACK)], pointer_type(SPELL_STACK), PRIMITIVE_STACK_PARENT do |f|
        f.returns(f.load(f.gep(f.arg(0), int(0), int(0, :size => 32))))
      end
    end
    
    def build_exception_primitives(builder)
      builder.external :setjmp, [pointer_type(:int8)], :int32
      builder.external :longjmp, [pointer_type(:int8), :int32], :void
      builder.global :jmpenv, [:int8] * 256 do
        LLVM::ConstantArray.const(LLVM::Int, 256) { |i| LLVM::Int(0) }
      end
      builder.global :exception, SPELL_EXCEPTION do
        builder.constant("")
      end
      builder.function [SPELL_VALUE], :void, PRIMITIVE_RAISE_EXCEPTION do |f|
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
      builder.function [:float], SPELL_VALUE, PRIMITIVE_NEW_FLOAT do |f|
        pointer = f.malloc(SPELL_FLOAT)
        f.store(f.flag_for(:float), f.flag_pointer(pointer))
        f.store(f.arg(0), f.box_pointer(pointer))
        f.returns(f.cast(pointer, SPELL_VALUE))
      end
      builder.function [SPELL_VALUE], SPELL_VALUE, PRIMITIVE_NEW_EXCEPTION do |f|
        pointer = f.malloc(SPELL_EXCEPTION)
        f.store(f.flag_for(:exception), f.flag_pointer(pointer))
        f.store(f.cast(f.arg(0), pointer_type(SPELL_STRING)), f.box_pointer(pointer))
        f.returns(f.cast(pointer, SPELL_VALUE))
      end
      builder.function [SPELL_VALUE, :int], SPELL_VALUE, PRIMITIVE_NEW_STRING do |f|
        pointer = f.variable_malloc(SPELL_STRING, f.arg(1))
        f.call("memcpy", f.variable_box_pointer(pointer), f.arg(0), f.arg(1))
        f.store(f.flag_for(:string), f.flag_pointer(pointer))
        f.store(f.sub(f.arg(1), int(1)), f.variable_length_pointer(pointer, SPELL_STRING))
        f.returns(f.cast(pointer, SPELL_VALUE))
      end
      builder.function [:int], SPELL_VALUE, PRIMITIVE_NEW_ARRAY do |f|
        pointer = f.variable_malloc(SPELL_ARRAY, f.arg(0))
        f.store(f.flag_for(:array), f.flag_pointer(pointer))
        f.store(f.arg(0), f.variable_length_pointer(pointer, SPELL_ARRAY))
        f.returns(f.cast(pointer, SPELL_VALUE))
      end
      builder.function [:int], SPELL_VALUE, PRIMITIVE_NEW_DICTIONARY do |f|
        pointer = f.variable_malloc(SPELL_DICTIONARY, f.arg(0))
        f.store(f.flag_for(:dictionary), f.flag_pointer(pointer))
        f.store(f.arg(0), f.variable_length_pointer(pointer, SPELL_DICTIONARY))
        f.returns(f.cast(pointer, SPELL_VALUE))
      end
      builder.function [:int, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_NEW_CONTEXT do |f|
        pointer = f.malloc(SPELL_CONTEXT)
        f.store(f.flag_for(:context), f.flag_pointer(pointer))
        f.store(f.load(f.get_global(:stack)), f.box_pointer(pointer))
        f.store(f.arg(1), f.nth_box_pointer(pointer, 2))
        f.store(f.arg(0), f.nth_box_pointer(pointer, 3))
        f.returns(f.cast(pointer, SPELL_VALUE))
      end
    end    
    
    def build_equality_primitives(builder)
      builder.function [SPELL_VALUE], SPELL_VALUE, PRIMITIVE_NOT do |f|
        f.returns(f.box_int(f.sub(int(1), f.unbox_int(f.arg(0)))))
      end
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_COMPARE_NUMERIC do |f|
        f.entry {
          f.condition(f.both_ints(f.arg(0), f.arg(1)), :onlyint, :mixed)
        }
        f.block(:onlyint) {
          result = f.icmp(:eq, f.as_int(f.arg(0)), f.as_int(f.arg(1)))
          f.returns(f.box_int(f.zext(result, type_by_name(:int))))
        }
        f.block(:mixed) {
          f.branch(:dofirst)
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
          f.branch(:result)
        }
        f.block(:p2float) {
          f.set_bookmark(:p2b, f.unbox(f.arg(1), SPELL_FLOAT))
          f.branch(:result)
        }
        f.block(:result) {
          p2 = f.phi :float,
                { :on => f.get_bookmark(:p2a), :return_from => :p2int },
                { :on => f.get_bookmark(:p2b), :return_from => :p2float }
          result = f.fcmp(:ueq, f.get_bookmark(:p1), p2)
          f.returns(f.box_int(f.zext(result, type_by_name(:int))))
        }
      end
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_COMPARE_STRING do |f|
        f.block(:entry) {
          f.condition(f.icmp(:eq, f.type_of(f.arg(1)), f.flag_for(:string)), :bothstrings, :unequal)
        }
        f.block(:bothstrings) {
          length1 = f.load(f.variable_length_pointer(f.arg(0), SPELL_STRING))
          length2 = f.load(f.variable_length_pointer(f.arg(1), SPELL_STRING))
          f.condition(f.icmp(:eq, length1, length2), :memcmp, :unequal)
        }
        f.block(:memcmp) {
          memcmp = f.call(:memcmp, f.unbox_variable(f.arg(0), SPELL_STRING),
                                   f.unbox_variable(f.arg(1), SPELL_STRING),
                                   f.load(f.variable_length_pointer(f.arg(0), SPELL_STRING)))
          f.condition(f.icmp(:eq, memcmp, int(0)), :equal, :unequal)
        }
        f.block(:equal) {
          f.returns(f.box_int(int(1)))
        }
        f.block(:unequal) {
          f.returns(f.box_int(int(0)))
        }        
      end
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_EQUALS do |f|
        f.entry {
          f.condition(f.is_int(f.arg(0)), :numeric, :checktype)
        }
        f.block(:checktype) {
          f.switch f.type_of(f.arg(0)), :other,
            { :on => f.flag_for(:float), :go_to => :numeric },
            { :on => f.flag_for(:string), :go_to => :string }
        }
        f.block(:numeric) {
          f.returns(f.primitive_compare_numeric(f.arg(0), f.arg(1)))
        }
        f.block(:string) {
          f.returns(f.primitive_compare_string(f.arg(0), f.arg(1)))
        }
        f.block(:other) {
          result = f.icmp(:eq, f.arg(0), f.arg(1))
          f.returns(f.box_int(f.zext(result, type_by_name(:int))))
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
    
    def build_variable_primitives(builder)
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_HEAD do |f|
        f.entry {
          f.condition(f.icmp(:eq, f.unbox_int(f.call(PRIMITIVE_IS_STRING, f.arg(0))), int(1)), :string, :maybearray)
        }
        f.block(:maybearray) {
          f.condition(f.icmp(:eq, f.unbox_int(f.call(PRIMITIVE_IS_ARRAY, f.arg(0))), int(1)), :array, :exception)
        }
        f.block(:array) {
          f.condition(f.icmp(:eq, f.load(f.variable_length_pointer(f.arg(0), SPELL_ARRAY)), int(0)), :emptyarray, :arrayhead)
        }
        f.block(:emptyarray) {
          f.primitive_raise(f.allocate_string("Head can't be called for an empty array"))
          f.unreachable
        }
        f.block(:string) {
          f.condition(f.icmp(:eq, f.load(f.variable_length_pointer(f.arg(0), SPELL_STRING)), int(0)), :emptystring, :stringhead)
        }
        f.block(:emptystring) {
          f.primitive_raise(f.allocate_string("Head can't be called for an empty string"))
          f.unreachable
        }
        f.block(:arrayhead) {
          f.returns(f.call(PRIMITIVE_ARRAY_ACCESS, f.arg(0), int(0)))
        }
        f.block(:stringhead) {
          f.returns(f.primitive_new_string(f.unbox_variable(f.arg(0), SPELL_STRING), int(2)))
        }
        f.block(:exception) {
          # FIX: display operand
          f.primitive_raise(f.allocate_string("Invalid argument"))
          f.unreachable
        }
      end
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_TAIL do |f|
        f.entry {
          f.condition(f.icmp(:eq, f.unbox_int(f.call(PRIMITIVE_IS_STRING, f.arg(0))), int(1)), :string, :maybearray)
        }
        f.block(:maybearray) {
          f.condition(f.icmp(:eq, f.unbox_int(f.call(PRIMITIVE_IS_ARRAY, f.arg(0))), int(1)), :array, :exception)
        }
        f.block(:array) {
          f.condition(f.icmp(:eq, f.load(f.variable_length_pointer(f.arg(0), SPELL_ARRAY)), int(0)), :emptyarray, :arraytail)
        }
        f.block(:emptyarray) {
          f.primitive_raise(f.allocate_string("Tail can't be called for an empty array"))
          f.unreachable
        }
        f.block(:string) {
          f.condition(f.icmp(:eq, f.load(f.variable_length_pointer(f.arg(0), SPELL_STRING)), int(0)), :emptystring, :stringtail)
        }
        f.block(:emptystring) {
          f.primitive_raise(f.allocate_string("Tail can't be called for an empty string"))
          f.unreachable
        }
        f.block(:arraytail) {
          length = f.load(f.variable_length_pointer(f.arg(0), SPELL_ARRAY))
          new_length = f.sub(length, int(1))
          array = f.primitive_new_array(new_length)
          array_pointer = f.cast(f.unbox_variable(array, SPELL_ARRAY), SPELL_VALUE)
          original_pointer = f.cast(f.gep(f.unbox_variable(f.arg(0), SPELL_ARRAY), int(1)), SPELL_VALUE)
          size = f.size_of_values(new_length)
          f.call("memcpy", array_pointer, original_pointer, size)
          f.returns(array)
        }
        f.block(:stringtail) {
          length = f.load(f.variable_length_pointer(f.arg(0), SPELL_STRING))
          new_length = f.sub(length, int(1))
          string_pointer = f.malloc_on_size(new_length)
          f.call("memcpy", string_pointer, f.gep(f.unbox_variable(f.arg(0), SPELL_STRING), int(1)), new_length)
          f.returns(f.primitive_new_string(string_pointer, length))
        }
        f.block(:exception) {
          # FIX: display operand
          f.primitive_raise(f.allocate_string("Invalid argument"))
          f.unreachable
        }
      end
      builder.function [SPELL_VALUE], SPELL_VALUE, PRIMITIVE_LENGTH do |f|
        f.entry {
          f.condition(f.is_int(f.arg(0)), :exception, :verify)
        }
        f.block(:verify) {
          f.switch f.type_of(f.arg(0)), :exception,
            { :on => f.flag_for(:array), :go_to => :array },
            { :on => f.flag_for(:string), :go_to => :string }
        }
        f.block(:string) {
          f.returns(f.box_int(f.load(f.variable_length_pointer(f.arg(0), SPELL_STRING))))
        }
        f.block(:array) {
          f.returns(f.box_int(f.load(f.variable_length_pointer(f.arg(0), SPELL_ARRAY))))
        }
        f.block(:exception) {
          # FIX: display operand
          f.primitive_raise(f.allocate_string("Invalid argument"))
          f.unreachable
        }        
      end
    end
    
    def build_string_primitives(builder)
      builder.function [SPELL_VALUE], SPELL_VALUE, PRIMITIVE_IS_STRING do |f|
        f.entry {
          f.condition(f.is_int(f.arg(0)), :exception, :verify)
        }
        f.block(:verify) {
          f.returns(f.box_int(f.zext(f.icmp(:eq, f.flag_for(:string), f.type_of(f.arg(0))), type_by_name(:int))))
        }
        f.block(:exception) {
          f.returns(f.box_int(int(0)))
        }
      end
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_CONCAT do |f|
        f.entry {
          f.condition(f.icmp(:eq, f.type_of(f.arg(1)), f.flag_for(:string)), :bothstrings, :exception)
        }
        f.block(:bothstrings) {
          length1 = f.load(f.variable_length_pointer(f.arg(0), SPELL_STRING))
          length2 = f.load(f.variable_length_pointer(f.arg(1), SPELL_STRING))
          new_length = f.add(f.add(length1, length2), int(1))
          string_pointer = f.malloc_on_size(new_length)
          f.call("memset", string_pointer, int(0), new_length)
          f.call("memcpy", string_pointer, f.unbox_variable(f.arg(0), SPELL_STRING), length1)
          f.call("memcpy", f.gep(string_pointer, length1), f.unbox_variable(f.arg(1), SPELL_STRING), length2)
          f.returns(f.primitive_new_string(string_pointer, new_length))
        }
        f.block(:exception) {
          # FIX: display operands
          f.primitive_raise(f.allocate_string("Can't concat string to non-string"))
          f.unreachable
        }
      end
      builder.function [SPELL_VALUE], SPELL_VALUE, PRIMITIVE_HASH do |f|
        f.entry {
          f.condition(f.icmp(:eq, f.unbox_int(f.call(PRIMITIVE_IS_STRING, f.arg(0))), int(1)), :initial, :exception)
        }
        f.block(:initial) {
          length = f.set_bookmark(:length, f.load(f.variable_length_pointer(f.arg(0), SPELL_STRING)))
          f.condition(f.icmp(:eq, length, int(0)), :result, :loop)
        }
        f.block(:loop) {
          var = f.partial_phi :int, { :on => int(0), :return_from => :initial }
          key = f.partial_phi :int32, { :on => int(0, :size => 32), :return_from => :initial }
          address = f.unbox_variable(f.arg(0), SPELL_STRING)
          value = f.load(f.gep(address, var))
          next_var = f.set_bookmark(:var, f.add(var, int(1)))
          next_key = f.set_bookmark(:key, f.add(f.zext(value, type_by_name(:int32)), f.mul(key, int(65599, :size => 32))))
          f.add_incoming var, { :on => next_var, :return_from => :loop }
          f.add_incoming key, { :on => next_key, :return_from => :loop }
          f.condition(f.icmp(:eq, next_var, f.get_bookmark(:length)), :result, :loop)
        }
        f.block(:result) {
          key = f.phi :int32, 
                            { :on => f.get_bookmark(:key), :return_from => :loop },
                            { :on => int(0, :size => 32), :return_from => :initial }
          hash = f.add(key, f.lshr(key, int(5, :size => 32)))
          f.returns(f.box_int(f.zext(hash, type_by_name(:int))))
        }
        f.block(:exception) {
          # FIX: display operands
          f.primitive_raise(f.allocate_string("Not a string"))
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
          f.condition(f.both_ints(f.arg(0), f.arg(1)), :addint, :other)
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
          f.condition(f.is_int(f.arg(0)), :p1int, :p1possiblefloat)
        }
        f.block(:p1int) {
          f.set_bookmark(:p1a, f.ui2fp(f.unbox_int(f.arg(0)), type_by_name(:float)))
          f.branch(:dosecond)
        }
        f.block(:p1possiblefloat) {
          f.condition(f.icmp(:eq, f.type_of(f.arg(0)), f.flag_for(:float)), :p1float, :exception)
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
          f.condition(f.is_int(f.arg(1)), :p2int, :p2possiblefloat)
        }
        f.block(:p2int) {
          f.set_bookmark(:p2a, f.ui2fp(f.unbox_int(f.arg(1)), type_by_name(:float)))
          f.branch(:result)
        }
        f.block(:p2possiblefloat) {
          f.condition(f.icmp(:eq, f.type_of(f.arg(1)), f.flag_for(:float)), :p2float, :exception)
        }
        f.block(:p2float) {
          f.set_bookmark(:p2b, f.unbox(f.arg(1), SPELL_FLOAT))
          f.branch(:result)
        }
        f.block(:result) {
          p2 = f.phi :float,
                { :on => f.get_bookmark(:p2a), :return_from => :p2int },
                { :on => f.get_bookmark(:p2b), :return_from => :p2float }
          f.returns(f.primitive_new_float(f.send(float_operator, f.get_bookmark(:p1), p2)))
        }
        f.block(:exception) {
          # FIX: display operands
          f.primitive_raise(f.allocate_string("Invalid numeric operation"))
          f.unreachable
        }
      end
    end
    
    def build_comparison_primitives(builder)
      build_comparison_primitive(builder, PRIMITIVE_LESS_THAN, :ult, :ult)
      build_comparison_primitive(builder, PRIMITIVE_LESS_THAN_OR_EQUAL_TO, :ule, :ule)
      build_comparison_primitive(builder, PRIMITIVE_GREATER_THAN, :ugt, :ugt)
      build_comparison_primitive(builder, PRIMITIVE_GREATER_THAN_OR_EQUAL_TO, :uge, :uge)
    end
    
    def build_comparison_primitive(builder, name, int_operator, float_operator)
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, name do |f|
        f.entry {
          f.condition(f.both_ints(f.arg(0), f.arg(1)), :compareint, :dofirst)
        }
        f.block(:compareint) {
          f.returns(f.box_int(f.zext(f.icmp(int_operator, f.unbox_int(f.arg(0)), f.unbox_int(f.arg(1))), type_by_name(:int))))
        }
        f.block(:dofirst) {
          f.condition(f.is_int(f.arg(0)), :p1int, :p1possiblefloat)
        }
        f.block(:p1int) {
          f.set_bookmark(:p1a, f.ui2fp(f.unbox_int(f.arg(0)), type_by_name(:float)))
          f.branch(:dosecond)
        }
        f.block(:p1possiblefloat) {
          f.condition(f.icmp(:eq, f.type_of(f.arg(0)), f.flag_for(:float)), :p1float, :exception)
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
          f.condition(f.is_int(f.arg(1)), :p2int, :p2possiblefloat)
        }
        f.block(:p2int) {
          f.set_bookmark(:p2a, f.ui2fp(f.unbox_int(f.arg(1)), type_by_name(:float)))
          f.branch(:result)
        }
        f.block(:p2possiblefloat) {
          f.condition(f.icmp(:eq, f.type_of(f.arg(1)), f.flag_for(:float)), :p2float, :exception)
        }
        f.block(:p2float) {
          f.set_bookmark(:p2b, f.unbox(f.arg(1), SPELL_FLOAT))
          f.branch(:result)
        }
        f.block(:result) {
          p2 = f.phi :float,
                { :on => f.get_bookmark(:p2a), :return_from => :p2int },
                { :on => f.get_bookmark(:p2b), :return_from => :p2float }
          f.returns(f.box_int(f.zext(f.fcmp(float_operator, f.get_bookmark(:p1), p2), type_by_name(:int))))
        }
        f.block(:exception) {
          # FIX: display operands
          f.primitive_raise(f.allocate_string("Invalid comparison"))
          f.unreachable
        }
      end
    end
    
    def build_conversion_primitives(builder)
      builder.external "sprintf", [SPELL_VALUE, SPELL_VALUE], :int32, :varargs => true
      builder.function [SPELL_VALUE], SPELL_VALUE, PRIMITIVE_INT_TO_STRING do |f|
        pointer = f.malloc_on_size(int(16, :size => 32))
        f.call("memset", pointer, int(0), int(16))
        size = f.call("sprintf", pointer, f.string_constant("%ld"), f.unbox_int(f.arg(0)))
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
          f.primitive_raise(f.primitive_concat(f.allocate_string("Unknown type: "), f.primitive_to_string(f.box_int(f.type_of(f.arg(0))))))
          f.unreachable
        }
      end
    end   
    
    def build_array_primitives(builder)
      builder.function [SPELL_VALUE], SPELL_VALUE, PRIMITIVE_IS_ARRAY do |f|
        f.entry {
          f.condition(f.is_int(f.arg(0)), :exception, :verify)
        }
        f.block(:verify) {
          f.returns(f.box_int(f.zext(f.icmp(:eq, f.flag_for(:array), f.type_of(f.arg(0))), type_by_name(:int))))
        }
        f.block(:exception) {
          f.returns(f.box_int(int(0)))
        }
      end
      builder.function [SPELL_VALUE, :int], SPELL_VALUE, PRIMITIVE_ARRAY_ACCESS do |f|
        f.entry {
          f.condition(f.is_int(f.arg(0)), :notanarray, :firstcheck)
        }
        f.block(:firstcheck) {
          f.condition(f.icmp(:eq, f.type_of(f.arg(0)), f.flag_for(:array)), :secondcheck, :notanarray)
        }
        f.block(:secondcheck) {
          f.condition(f.icmp(:uge, f.arg(1), int(0)), :thirdcheck, :exception)
        }
        f.block(:thirdcheck) {
          length = f.load(f.variable_length_pointer(f.arg(0), SPELL_ARRAY))
          f.condition(f.icmp(:ult, f.arg(1), length), :inbounds, :exception)
        }
        f.block(:inbounds) {
          f.returns(f.load(f.gep(f.unbox_variable(f.arg(0), SPELL_ARRAY), f.arg(1))))
        }
        f.block(:notanarray) {
          f.primitive_raise(f.allocate_string("Not an array"))
          f.unreachable
        }
        f.block(:exception) {
          f.primitive_raise(f.allocate_string("Array access out of bounds"))
          f.unreachable
        }
      end
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_ARRAY_CONCAT do |f|
        f.entry {
          f.condition(f.icmp(:eq, f.unbox_int(f.call(PRIMITIVE_IS_ARRAY, f.arg(0))), int(1)), :secondparam, :exception)
        }
        f.block(:secondparam) {
          f.condition(f.icmp(:eq, f.unbox_int(f.call(PRIMITIVE_IS_ARRAY, f.arg(1))), int(1)), :botharrays, :exception)          
        }
        f.block(:botharrays) {
          length1 = f.load(f.variable_length_pointer(f.arg(0), SPELL_ARRAY))
          length2 = f.load(f.variable_length_pointer(f.arg(1), SPELL_ARRAY))
          new_length = f.add(length1, length2)
          array = f.primitive_new_array(new_length)
          array_pointer = f.cast(f.unbox_variable(array, SPELL_ARRAY), SPELL_VALUE)
          original_pointer1 = f.cast(f.unbox_variable(f.arg(0), SPELL_ARRAY), SPELL_VALUE)
          original_pointer2 = f.cast(f.unbox_variable(f.arg(1), SPELL_ARRAY), SPELL_VALUE)
          size1 = f.size_of_values(length1)
          size2 = f.size_of_values(length2)
          f.call("memcpy", array_pointer, original_pointer1, size1)
          f.call("memcpy", f.gep(array_pointer, size1), original_pointer2, size2)
          f.returns(array)
        }
        f.block(:exception) {
          f.primitive_raise(f.allocate_string("Concat operands must be arrays"))
          f.unreachable
        }
      end
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_ARRAY_CONS do |f|
        f.entry {
          f.condition(f.icmp(:eq, f.unbox_int(f.call(PRIMITIVE_IS_ARRAY, f.arg(1))), int(1)), :cons, :exception)
        }
        f.block(:cons) {
          length = f.load(f.variable_length_pointer(f.arg(1), SPELL_ARRAY))
          new_length = f.add(length, int(1))
          array = f.primitive_new_array(new_length)
          array_pointer = f.cast(f.unbox_variable(array, SPELL_ARRAY), SPELL_VALUE)
          original_pointer = f.cast(f.unbox_variable(f.arg(1), SPELL_ARRAY), SPELL_VALUE)
          offset = f.size_of_values(int(1))
          size = f.size_of_values(length)
          f.store(f.arg(0), f.gep(array_pointer, int(0)))
          f.call("memcpy", f.gep(array_pointer, offset), original_pointer, size)
          f.returns(array)
        }
        f.block(:exception) {
          f.primitive_raise(f.allocate_string("Cons's second operand must be an array"))
          f.unreachable
        }
      end
    end

    def build_dictionary_primitives(builder)
      builder.function [SPELL_VALUE, SPELL_VALUE], SPELL_VALUE, PRIMITIVE_DICTIONARY_ACCESS do |f|
        f.entry {
          f.condition(f.is_int(f.arg(0)), :notadictionary, :firstcheck)
        }
        f.block(:firstcheck) {
          f.condition(f.icmp(:eq, f.type_of(f.arg(0)), f.flag_for(:dictionary)), :initial, :notadictionary)
        }
        f.block(:initial) {
          f.set_bookmark(:hash, f.unbox_int(f.primitive_hash(f.arg(1))))
          f.set_bookmark(:length, f.load(f.variable_length_pointer(f.arg(0), SPELL_DICTIONARY)))
          f.branch(:index)
        }
        f.block(:index) {
           index = f.partial_phi :int
           f.set_bookmark(:index, index)
           f.branch(:loop)
        }
        f.block(:compare) {
          item_pointer = f.gep(f.unbox_variable(f.arg(0), SPELL_DICTIONARY), f.get_bookmark(:index))
          item = f.load(f.gep(item_pointer, int(0), int(0, :size => 32)))
          f.condition(f.icmp(:eq, f.get_bookmark(:hash), f.unbox_int(item)), :found, :next)
        }
        f.block(:next) {
          f.set_bookmark(:next, f.add(f.get_bookmark(:index), int(1)))
          f.branch(:index)
        }
        f.block(:loop) {
          f.add_incoming f.get_bookmark(:index), { :on => int(0), :return_from => :initial }
          f.add_incoming f.get_bookmark(:index), { :on => f.get_bookmark(:next), :return_from => :next }
          f.condition(f.icmp(:ult, f.get_bookmark(:index), f.get_bookmark(:length)), :compare, :found)
        }
        f.block(:found) {
          result = f.phi :int, 
                    { :on => f.get_bookmark(:index), :return_from => :compare },
                    { :on => int(-1), :return_from => :loop }
          f.set_bookmark(:result, result)
          f.condition(f.icmp(:eq, int(-1), result), :exception, :result)
        }
        f.block(:result) {
          item_pointer = f.gep(f.unbox_variable(f.arg(0), SPELL_DICTIONARY), f.get_bookmark(:result))
          item = f.load(f.gep(item_pointer, int(0), int(1, :size => 32)))
          f.returns(item)
        }
        f.block(:exception) {
          f.primitive_raise(f.allocate_string("Key not in dictionary"))
          f.unreachable          
        }
        f.block(:notadictionary) {
          f.primitive_raise(f.allocate_string("Not a dictionary"))
          f.unreachable
        }
      end
    end
    
    def build_closure_primitives(builder)
      (0..PRIMITIVE_SPELL_APPLY_MAX_DIRECT_PARAMETERS).each do |index|
        builder.function [SPELL_VALUE] + [SPELL_VALUE] * index, SPELL_VALUE, PRIMITIVE_SPELL_APPLY_ROOT + index.to_s  do |f|
          f.entry {
            f.condition(f.is_int(f.arg(0)), :notablock, :firstcheck)
          }
          f.block(:firstcheck) {
            f.condition(f.icmp(:eq, f.type_of(f.arg(0)), f.flag_for(:context)), :secondcheck, :notablock)
          }
          f.block(:secondcheck) {
            f.condition(f.icmp(:eq, f.unbox_nth(f.arg(0), SPELL_CONTEXT, 3), int(index)), :invoke, :blockmismatch)
          }
          f.block(:invoke) {
            function = f.cast(f.unbox_nth(f.arg(0), SPELL_CONTEXT, 2), pointer_type(function_type([SPELL_VALUE] * index, SPELL_VALUE)))
            arguments = (0...index).collect { |i| f.arg(i + 1) }
            arguments << f.arg(0)
            f.returns(f.call(function, *arguments))
          }
          f.block(:blockmismatch) {
            p1 = f.allocate_string("Apply called with ")
            p2 = f.primitive_to_string(f.box_int(int(index)))
            p3 = f.allocate_string(" arguments; passed block needs ")
            p4 = f.primitive_to_string(f.box_int(f.unbox_nth(f.arg(0), SPELL_CONTEXT, 3)))
            p5 = f.allocate_string(" arguments")
            error = f.primitive_concat(f.primitive_concat(f.primitive_concat(f.primitive_concat(p1, p2), p3), p4), p5)
            f.primitive_raise(error)
            f.unreachable
          }
          f.block(:notablock) {
            f.primitive_raise(f.allocate_string("Not a block"))
            f.unreachable
          }
        end
      end
    end
    
  end
  
end