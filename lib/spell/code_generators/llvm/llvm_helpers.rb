class FunctionBuilderWrapper

  def flag_for(type)
    case type
    when :float
      int(FLOAT_FLAG)
    when :exception
      int(EXCEPTION_FLAG)
    when :string
      int(STRING_FLAG)
    when :array
      int(ARRAY_FLAG)
    when :dictionary
      int(DICTIONARY_FLAG)
    when :context
      int(CONTEXT_FLAG)
    end
  end

  def flag_pointer(value)
    gep(value, int(0), int(0, :size => 32))
  end
  
  def type_of(value)
    load(cast(value, pointer_type(:int)))
  end
  
  def box_pointer(value)
    gep(value, int(0), int(1, :size => 32))
  end
  
  def nth_box_pointer(value, index)
    gep(value, int(0), int(index, :size => 32))
  end

  def variable_box_pointer(value)
    gep(value, int(0), int(2, :size => 32), int(0))
  end

  def variable_length_pointer(value, type)
    gep(cast(value, pointer_type(type)), int(0), int(1, :size => 32))
  end

  def unbox(pointer, type)
    load(box_pointer(cast(pointer, pointer_type(type))))
  end

  def unbox_nth(pointer, type, index)
    load(nth_box_pointer(cast(pointer, pointer_type(type)), index))
  end

  def unbox_variable(pointer, type)
    variable_box_pointer(cast(pointer, pointer_type(type)))
  end
  
  def as_int(value)
    ptr2int(value, :int)
  end
  
  def is_int(value)
    icmp(:eq, send(:and, as_int(value), int(1)), int(1))
  end

  def is_not_int(value)
    icmp(:ne, send(:and, as_int(value), int(1)), int(1))
  end
  
  def unbox_int(value)
    lshr(as_int(value), int(1))
  end
  
  def box_int(value)
    int2ptr(add(shl(value, int(1)), int(1)), SPELL_VALUE)
  end
  
  def malloc(type)
    cast(call("malloc", size_of(type)), pointer_type(type))
  end
  
  def variable_malloc(type, length)
    cast(call("malloc", variable_size_of(type, length)), pointer_type(type))
  end

  def malloc_on_size(size)
    call("malloc", trunc(size, type_by_name(:int32)))
  end
  
  def size_of(type)
    ptr2int(gep(pointer_type(type).null_pointer, int(1)), :int32)
  end
  
  def variable_size_of(type, length)
    ptr2int(gep(pointer_type(type).null_pointer, int(0), int(2, :size => 32), length), :int32)
  end
  
  def size_of_values(length)
    ptr2int(gep(pointer_type(pointer_type(SPELL_VALUE)).null_pointer, length), :int)
  end
  
  def both_ints(value1, value2)
    icmp(:eq, self.and(self.and(as_int(value1), as_int(value2)), int(1)), int(1))
  end

  def any_ints(value1, value2)
    icmp(:eq, self.and(self.or(as_int(value1), as_int(value2)), int(1)), int(1))
  end
  
  def primitive_new_float(value)
    call(PRIMITIVE_NEW_FLOAT, value)
  end
  
  def primitive_new_string(value, size)
    call(PRIMITIVE_NEW_STRING, value, size)
  end
  
  def primitive_new_exception(string_pointer)
    call(PRIMITIVE_NEW_EXCEPTION, string_pointer)
  end
  
  def primitive_new_array(size)
    call(PRIMITIVE_NEW_ARRAY, size)
  end

  def primitive_new_dictionary(size)
    call(PRIMITIVE_NEW_DICTIONARY, size)
  end
  
  def primitive_new_context(arguments_size, function_pointer, parent_context)
    call(PRIMITIVE_NEW_CONTEXT, arguments_size, function_pointer, parent_context)
  end
  
  def primitive_raise(string_pointer)
    call(PRIMITIVE_RAISE_EXCEPTION, primitive_new_exception(string_pointer))
  end
  
  def primitive_concat(string1, string2)
    call(PRIMITIVE_CONCAT, string1, string2)
  end
  
  def primitive_to_string(value)
    call(PRIMITIVE_TO_STRING, value)
  end
  
  def primitive_array_access(pointer, index)
    call(PRIMITIVE_ARRAY_ACCESS, pointer, index)
  end

  def primitive_dictionary_access(pointer, key_pointer)
    call(PRIMITIVE_DICTIONARY_ACCESS, pointer, key_pointer)
  end
  
  def primitive_compare_string(value1, value2)
    call(PRIMITIVE_COMPARE_STRING, value1, value2)
  end

  def primitive_compare_numeric(value1, value2)
    call(PRIMITIVE_COMPARE_NUMERIC, value1, value2)
  end
  
  def primitive_hash(value)
    call(PRIMITIVE_HASH, value)
  end
  
  def primitive_stack_parent(value)
    call(PRIMITIVE_STACK_PARENT, value)
  end

  def primitive_context_parent(value)
    call(PRIMITIVE_CONTEXT_PARENT, value)
  end
  
  def allocate_float(value)
    primitive_new_float(float(value))
  end
  
  def allocate_string(value)
    primitive_new_string(string_constant(value), int(value.size + 1))
  end
  
  def allocate_context(arguments_size, function, in_closure)
    primitive_new_context(int(arguments_size), 
                          cast(function, SPELL_VALUE), 
                          in_closure ? arg(:last) : SPELL_VALUE.null_pointer)
  end
  
  def string_constant(value)
    string = global(random_const_name, [:int8] * (value.size + 1)) do
      constant(value)
    end
    gep(string, int(0), int(0))
  end
  
  def explicit_stack(arguments_size, bindings_size)
    old_stack = set_bookmark(:old_stack, builder.load(get_global(:stack)))
    stack = set_bookmark(:stack, variable_malloc(SPELL_STACK, int(arguments_size + bindings_size)))
    store(old_stack, gep(stack, int(0), int(0, :size => 32)))
    store(stack, get_global(:stack))
    arguments_size.times do |index|
      store(arg(index), stack_at(index))
    end
  end
  
  def unwind_stack
    store(get_bookmark(:old_stack), get_global(:stack))
  end
  
  def stack_at(index)
    gep(variable_box_pointer(get_bookmark(:stack)), int(index))
  end
  
  def context_stack_at(stack, index)
    gep(variable_box_pointer(stack), int(index))
  end
    
end