module Bytecode

  class DictionaryNew

    include Storable
    
    def inspect
      "dictionary new"
    end

  end

  class DictionaryGet
    
    include Storable

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def inspect
      "dictionary get #{@name}"
    end

  end

  class DictionarySet
    
    include Storable

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def inspect
      "dictionary set #{@name}"
    end

  end

end
