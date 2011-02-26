module Bytecode

  class Apply
    
    include Storable

    def inspect
      "apply"
    end

  end

  class Closure
    
    include Storable

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
    
    def self.load(arguments_size, literal_frame_size, instructions_size)
      new(arguments_size.to_i, literal_frame_size.to_i, instructions_size.to_i)
    end

  end

  class Up
    
    include Storable

    attr_reader :index
    attr_reader :distance

    def initialize(index, distance)
      @index, @distance = index, distance
    end

    def inspect
      "up #{@index} #{@distance}"
    end
    
    def self.load(index, distance)
      new(index.to_i, distance.to_i)
    end

  end

  class Close
    
    include Storable

    def inspect
      "close"
    end

  end

end
