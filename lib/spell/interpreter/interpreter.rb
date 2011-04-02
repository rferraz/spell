class Interpreter

  def initialize(code, debug, *root_paths)
    @debug = debug
    @code = code
    @root_paths = root_paths
    @primitives = {}
    initialize_default_primitives
  end

  def attach_primitive(name, method)
    @primitives[name] = method
  end

  def attach_primitives(primitives)
    @primitives.merge!(primitives)
  end

  def run
    if is_dump?
      load_passes.run(@code)
    else
      run_passes.run(@code)
    end
  end
  
  def dump
    puts dump_passes.run(@code)
  end

  def self.run(code)
    new(code).run
  end
  
  protected
  
  def initialize_default_primitives
    primitives = {
        "show" => lambda { |value| print value ; value },
        "range" => lambda { |bottom, top| bottom <= top ? (bottom..top).to_a : (top..bottom).to_a.reverse },
        "to#string" => lambda { |value| value.to_s },
        "empty" => lambda { |list| list.empty? },
        "head" => lambda { |list| list.first },
        "tail" => lambda { |list| first, *rest = list ; rest },
        "length" => lambda { |list| list.size },
        ":" => lambda { |element, list| list.unshift(element) ; list },
        "++" => lambda { |a, b| a + b },
        "reverse" => lambda { |list| list.reverse },
        "math#sqrt" => Math.method(:sqrt),
        "math#round" => lambda { |v| v.round },
        "compare" => lambda { |a, b| a < b ? "lt" : a > b ? "gt" : "eq" },
        "assert" => lambda { |v, m| v || raise(m) }
    }
    attach_primitives(primitives)
  end
  
  def is_dump?
    @code.starts_with?(Dumper::HEADER)
  end
  
  def run_passes
    PassManager.
      chain(Parser, @root_paths).
      chain(Analyzer, @primitives.keys + VM::PRIMITIVES).
      chain(BytecodeGenerator).
      chain(VM, @primitives, @debug)
  end

  def dump_passes
    PassManager.
      chain(Parser, @root_paths).
      chain(Analyzer, @primitives.keys + VM::PRIMITIVES).
      chain(BytecodeGenerator).
      chain(Dumper)
  end
  
  def load_passes
    PassManager.
      chain(Loader).
      chain(VM, @primitives, @debug)
  end

end
