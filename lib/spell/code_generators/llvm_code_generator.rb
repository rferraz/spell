require "llvm/core"
require "llvm/execution_engine"
require "llvm/transforms/scalar"
require "llvm/dsl/dsl"

class LLVMCodeGenerator
  
  INT_FLAG = 1
  
  FLOAT_FLAG = 5
  
  ORIGINAL_MAIN_METHOD_NAME = "main"
  MAIN_METHOD_NAME = "__main"
  
  UNBOX = "__unbox__"
  NEW_FLOAT = "__new_float__"
  
  SIZE_INT = [1.to_i].pack("l!").size
  SIZE_FLOAT = [1.to_f].pack("f").size
  
  MALLOC_TYPE = :int8

  def initialize(primitive_builder_class)
    @primitive_builder_class = primitive_builder_class
  end
  
  def run(ast)
    reset_builders
    build_internal_primitives
    reset_primitives(@primitive_builder_class)
    reset_main_method(ast)
    build_any(ast)
    builder
  end

  def method_missing(method, *args, &block)
    if method.to_s =~ /^build_(.*)$/
      raise "The class #{$1} is not a valid AST node"
    else
      super
    end
  end

  protected
  
  def reset_builders
    @builders ||= [simple_module("spell")]
  end
  
  def builder
    @builders.last
  end
    
  def enter_builder(builder)
    @builders.push(builder)
  end
  
  def leave_builder
    @builders.pop
  end

  def reset_primitives(builder_class)
    builder_class.build(builder)
  end
  
  def reset_main_method(ast)
    @main_method = ast.statements.find { |method| method.name == "main" } ||
      ast.statement.first
  end
  
  def enter_method(method)
    @method = method
  end
  
  def current_method
    @method
  end
  
  def build_any(ast)
    send("build_#{ast.class.name.demodulize.underscore}", ast)
  end

  def build_list(list)
    list.collect { |item| build_any(item) }.flatten
  end
  
  def build_program(program)
    build_list(program.statements)
    builder.function [], pointer_type(MALLOC_TYPE), ORIGINAL_MAIN_METHOD_NAME do |f|
      f.returns(f.call(UNBOX, f.call(MAIN_METHOD_NAME)))
    end
  end
  
  def build_method(method)
    name = method.name == ORIGINAL_MAIN_METHOD_NAME ? MAIN_METHOD_NAME : method.name
    enter_method(method)
    builder.function [], pointer_type(MALLOC_TYPE), name do |f|
      enter_builder(f)
      begin
        f.returns(build_list(method.body).last)
      ensure
        leave_builder
      end
    end
  end
  
  def build_load(load)
    if load.type == :const
      value = current_method.literal_frame[load.index]
      case value
      when ::Fixnum
        int(mask_int(value))
      when ::Float
        allocate_float(value)
      end
    end
  end
  
  def build_internal_primitives
    builder.external "malloc", [:int], pointer_type(MALLOC_TYPE)
    builder.external "free", [pointer_type(MALLOC_TYPE)], :void
    builder.function [:float], pointer_type(MALLOC_TYPE), NEW_FLOAT do |f|
      pointer = f.call("malloc", int(SIZE_INT + SIZE_FLOAT))
      ip = f.bit_cast(pointer, pointer_type(:int))
      fp = f.bit_cast(f.gep(pointer, int(1)), pointer_type(:float))
      f.store(flag(FLOAT_FLAG), ip)
      f.store(f.arg(0), fp)
      f.returns(pointer)
    end
    builder.function [pointer_type(MALLOC_TYPE)], pointer_type(MALLOC_TYPE), UNBOX do |f|
      f.returns(f.gep(f.arg(0), int(1)))
    end
  end
  
  def flag(value)
    int(value)
  end
  
  def allocate_float(value)
    builder.call(NEW_FLOAT, float(value))
  end
  
  def mask_int(value)
    (value << 1) | INT_FLAG
  end
   
end