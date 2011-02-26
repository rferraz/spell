module Bytecode

  class ArrayNew
    
    include Storable
    
    def inspect
      "array new"
    end

  end

  class ArrayGet
    
    include Storable

    def inspect
      "array get"
    end

  end

  class ArraySet
    
    include Storable

    def inspect
      "array set"
    end

  end

end
