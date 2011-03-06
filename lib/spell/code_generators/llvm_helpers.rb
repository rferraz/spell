class FunctionBuilderWrapper
  
  def flag_pointer(value)
    cast(value, pointer_type(:int))
  end
  
  def box_pointer(value, type)
    cast(gep(value, int(SIZE_INT)), pointer_type(type))
  end
  
  def unbox(pointer, type)
    load(box_pointer(pointer, type))
  end
  
  def box(value, type)
    cast(get_boxed_value(value), pointer_type(type))
  end
  
  def unbox_int(value)
    lshr(ptr2int(value, :int), int(1))
  end
  
  def malloc(size)
    call("malloc", int(size, :size => 32))
  end
  
  def new_float(value)
    call(PRIMITIVE_NEW_FLOAT, value)
  end
  
end