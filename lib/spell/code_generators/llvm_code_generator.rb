class LLVMCodeGenerator
  
  def initialize(primitive_builder_class)
    @primitive_builder_class = primitive_builder_class
  end
  
  def run(ast)
    reset_builders
    build_internal_primitives
    reset_primitives(@primitive_builder_class)
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
  
  def module_builder
    @builders.first
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
    LLVMPrimitivesBuilder.build_main(builder)
  end
  
  def build_method(method)
    name = method.name == ORIGINAL_MAIN_METHOD_NAME ? MAIN_METHOD_NAME : method.name
    enter_method(method)
    builder.function [SPELL_VALUE] * method.arguments_size, SPELL_VALUE, name do |f|
      enter_builder(f)
      begin
        f.returns(build_list(method.body).last)
      ensure
        leave_builder
      end
    end
  end
  
  def build_invoke(invoke)
    case invoke.message
    when "=="
      builder.call(PRIMITIVE_EQUALS, *build_list(invoke.parameters))
    when "+"
      builder.call(PRIMITIVE_PLUS, *build_list(invoke.parameters))
    else
      builder.call(invoke.message, *build_list(invoke.parameters))
    end
  end
  
  def build_load(load)
    if load.type == :const
      value = current_method.literal_frame[load.index]
      case value
      when ::Fixnum
        builder.int2ptr(int(mask_int(value)), SPELL_VALUE)
      when ::Float
        builder.allocate_float(value)
      when ::String
        # FIX: parser is generating the incorrect string value
        builder.allocate_string(value[1, value.size - 2])
      end
    else
      builder.arg(load.index)
    end
  end
  
  def build_internal_primitives
    LLVMPrimitivesBuilder.build(builder)
  end
   
  def allocate_float(value)
    builder.primitive_new_float(float(value))
  end

  def mask_int(value)
    (value << 1) | INT_FLAG
  end
  
end