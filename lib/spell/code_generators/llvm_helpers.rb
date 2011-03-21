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

  def variable_box_pointer(value)
    gep(value, int(0), int(2, :size => 32), int(0))
  end

  def variable_length_pointer(value, type)
    gep(cast(value, pointer_type(type)), int(0), int(1, :size => 32))
  end

  def unbox(pointer, type)
    load(box_pointer(cast(pointer, pointer_type(type))))
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
  
  def both_ints(value1, value2)
    icmp(:eq, self.and(self.and(as_int(value1), as_int(value2)), int(1)), int(1))
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
  
  def primitive_raise(string_pointer)
    call(PRIMITIVE_RAISE_EXCEPTION, primitive_new_exception(string_pointer))
  end
  
  def primitive_concat(string1, string2)
    call(PRIMITIVE_CONCAT, string1, string2)
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
  
  def allocate_float(value)
    primitive_new_float(float(value))
  end
  
  def allocate_string(value)
    primitive_new_string(string_constant(value), int(value.size + 1))
  end
  
  def string_constant(value)
    string = global(random_const_name, [:int8] * (value.size + 1)) do
      constant(value)
    end
    gep(string, int(0), int(0))
  end
  
  private
  
  def random_const_name
    base = rand.to_s
    "const_" + base[2, base.length - 2]
  end
  
end