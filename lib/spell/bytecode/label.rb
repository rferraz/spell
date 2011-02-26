module Bytecode

  class Label
    
    include Storable

    attr_reader :name
    attr_reader :arguments_size
    attr_reader :bindings_size
    attr_reader :literal_frame_size

    def initialize(name, arguments_size, bindings_size, literal_frame_size)
      @name, @arguments_size, @bindings_size, @literal_frame_size = name, arguments_size, bindings_size, literal_frame_size
    end

    def inspect
      "label #{@name} #{@arguments_size} #{@bindings_size} #{@literal_frame_size}"
    end
    
    def self.load(name, arguments_size, bindings_size, literal_frame_size)
      new(name, arguments_size.to_i, bindings_size.to_i, literal_frame_size.to_i)
    end

  end

end
