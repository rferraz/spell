require "llvm/core"
require "llvm/execution_engine"
require "llvm/transforms/scalar"
require "llvm/dsl/dsl"

class LLVMCodeGenerator
  
  ORIGINAL_MAIN_METHOD_NAME = "main"
  MAIN_METHOD_NAME = "__main"

  def initialize(primitive_builder_class)
    @primitive_builder_class = primitive_builder_class
  end
  
  def run(ast)
    reset_builders
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
    builder.function [], :int, ORIGINAL_MAIN_METHOD_NAME do |f|
      f.returns(f.call(MAIN_METHOD_NAME))
    end
  end
  
  def build_method(method)
    name = method.name == ORIGINAL_MAIN_METHOD_NAME ? MAIN_METHOD_NAME : method.name
    enter_method(method)
    builder.function [], :int, name do |f|
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
        int(value)
      end
    end
  end
    
end
