module Ast

  class Load
    
    attr_reader :type
    attr_reader :index

    def initialize(type, index)
      @type, @index = type, index
    end

    def to_sexp
      [:load, @type, @index]
    end

  end

end
