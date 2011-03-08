class FunctionBuilderWrapper

  def flag_for(type)
    case type
    when :float
      int(FLOAT_FLAG)
    when :exception
      int(EXCEPTION_FLAG)
    end
  end

  def flag_pointer(value)
    gep(value, int(0), int(0, :size => 32))
  end
  
  def box_pointer(value)
    gep(value, int(0), int(1, :size => 32))
  end
  
  def _box_pointer(value, type)
    cast(gep(value, int(SIZE_INT)), pointer_type(type))
  end
  
  def unbox(pointer, type)
    load(box_pointer(cast(pointer, pointer_type(SPELL_FLOAT))))
  end
  
  def as_int(value)
    ptr2int(value, :int)
  end
  
  def is_int(value)
    icmp(:eq, send(:and, as_int(value), int(1)), int(1))
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
  
  def size_of(type)
    ptr2int(gep(pointer_type(type).null_pointer, int(1)), :int32)
  end
  
  def primitive_new_float(value)
    call(PRIMITIVE_NEW_FLOAT, value)
  end
  
  def primitive_raise(value)
    string_type = array_type(:int8, value.size + 1)
    string_pointer = malloc(string_type)
    store(LLVM::ConstantArray.string(value), string_pointer)
    pointer = malloc(SPELL_EXCEPTION)
    store(flag_for(:exception), flag_pointer(pointer))
    store(cast(string_pointer, pointer_type(:int8)), box_pointer(pointer))
    call(PRIMITIVE_RAISE, pointer)
  end
  
end