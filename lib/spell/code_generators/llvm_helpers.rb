class FunctionBuilderWrapper
  
  def get_flag(value)
    cast(value, pointer_type(:int))
  end
  
  def get_box(value, type)
    cast(gep(value, int(1)), pointer_type(type))
  end
  
  def unbox(pointer, type)
    load(get_box(pointer, type))
  end
  
  def box(value, type)
    cast(get_boxed_value(value), pointer_type(type))
  end
  
  def unbox_int(value)
    lshr(ptr2int(value, :int), int(1))
  end
  
  def malloc(size)
    call("malloc", int(size))
  end
  
  def new_float(value)
    call(PRIMITIVE_NEW_FLOAT, value)
  end
  
end