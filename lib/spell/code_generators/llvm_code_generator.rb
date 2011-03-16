class LLVMCodeGenerator
  
  PRIMITIVES_MAPPINGS = {
    "==" => PRIMITIVE_EQUALS,
    "!=" => PRIMITIVE_NOT_EQUALS,
    "+" => PRIMITIVE_PLUS,
    "-" => PRIMITIVE_MINUS,
    "*" => PRIMITIVE_TIMES,
    "/" => PRIMITIVE_DIVIDE,
    "<" => PRIMITIVE_LESS_THAN,
    ">" => PRIMITIVE_GREATER_THAN,
    "<=" => PRIMITIVE_LESS_THAN_OR_EQUAL_TO,
    ">=" => PRIMITIVE_GREATER_THAN_OR_EQUAL_TO    
  }
  
  PRIMITIVES = PRIMITIVES_MAPPINGS.keys
  
  def initialize(primitive_builder_class)
    @primitive_builder_class = primitive_builder_class
    @defined_primitives = {}
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
  
  def defined_primitives
    @defined_primitives.merge(PRIMITIVES_MAPPINGS)
  end
  
  def define_primitive(name, primitive)
    @defined_primitives[name] = primitive
  end
  
  def is_primitive?(name)
    defined_primitives.keys.include?(name)
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
    if method.body.first.is_a?(Ast::Primitive)
      define_primitive(method.name, method.body.first.name)
    else
      builder.function [SPELL_VALUE] * method.arguments_size, SPELL_VALUE, name do |f|
        enter_builder(f)
        begin
          if method.body.first.is_a?(Ast::Case)
            build_list(method.body)
          else
            builder.returns(build_list(method.body).last)
          end
        ensure
          leave_builder
        end
      end
    end
  end
  
  def build_invoke(invoke)
    message = is_primitive?(invoke.message) ? defined_primitives[invoke.message] : invoke.message
    builder.call(message, *build_list(invoke.parameters))
  end
  
  def build_case(case_statement)
    builder.block(:entry) do
      builder.branch("test0")
    end
    case_statement.items.each_with_index do |item, index|
      if item == case_statement.items.last
        if item.condition.is_a?(Ast::NullCaseCondition)
          builder.block("test" + index.to_s) do
            builder.branch("result" + index.to_s)
          end
        else
          builder.block("test" + index.to_s) do
            builder.condition(builder.icmp(:eq, builder.unbox_int(build_any(item.condition)), int(1)), "result" + index.to_s, "exception")
          end
          builder.block("exception") do
            builder.primitive_raise(builder.allocate_string("Case condition is not exhaustive"))
            builder.unreachable
          end
        end
      else
        builder.block("test" + index.to_s) do
          builder.condition(builder.icmp(:eq, builder.unbox_int(build_any(item.condition)), int(1)), "result" + index.to_s, "test" + (index + 1).to_s)
        end
      end
      builder.block("result" + index.to_s) do
        builder.returns(build_any(item.result))
      end
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
      builder.get_bookmark("value" + load.index.to_s) || builder.arg(load.index)
    end
  end
  
  def build_array_literal(array)
    pointer = builder.primitive_new_array(int(array.items.size))
    array_pointer = builder.unbox_variable(pointer, SPELL_ARRAY)
    array.items.each_with_index do |item, index|
      builder.store(builder.cast(build_any(item), SPELL_VALUE), builder.gep(array_pointer, int(index)))
    end
    pointer
  end
  
  def build_array_item(array_item)
    build_any(array_item.expression)
  end
  
  def build_array_access(array_access)
    builder.primitive_array_access(builder.cast(build_any(array_access.target), SPELL_VALUE), builder.unbox_int(build_any(array_access.index)))
  end
  
  def build_store(store)
    builder.set_bookmark("value" + store.index.to_s, build_any(store.body))
  end
  
  def build_internal_primitives
    LLVMPrimitivesBuilder.build(builder)
  end
   
  def mask_int(value)
    (value << 1) | INT_FLAG
  end
  
end