module Ast

  class Up

    def initialize(index, distance)
      @index, @distance = index, distance
    end

    def to_sexp
      [:up, @index, @distance]
    end

  end

end
