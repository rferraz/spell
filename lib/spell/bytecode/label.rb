module Bytecode

  class Label

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

  end

end
