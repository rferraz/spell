module Bytecode

  class Apply

    def inspect
      "apply"
    end

  end

  class Closure

    attr_reader :arguments_size
    attr_reader :literal_frame_size
    attr_reader :instructions_size

    def initialize(arguments_size, literal_frame_size, instructions_size)
      @arguments_size, @literal_frame_size, @instructions_size =
        arguments_size, literal_frame_size, instructions_size
    end

    def inspect
      "closure #{@arguments_size} #{@literal_frame_size} #{@instructions_size}"
    end

  end

  class Up

    attr_reader :index
    attr_reader :distance

    def initialize(index, distance)
      @index, @distance = index, distance
    end

    def inspect
      "up #{@index} #{@distance}"
    end

  end

  class Close

    def inspect
      "close"
    end

  end

end
