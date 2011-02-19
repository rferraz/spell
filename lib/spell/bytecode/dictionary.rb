module Bytecode

  class Dictionary

    def inspect
      "dictionary new"
    end

  end

  class DictionaryGet

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def inspect
      "dictionary get #{@name}"
    end

  end

  class DictionarySet

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def inspect
      "dictionary set #{@name}"
    end

  end

end
