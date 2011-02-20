module Ast

  class Up

    attr_reader :index
    attr_reader :distance

    def initialize(index, distance)
      @index, @distance = index, distance
    end

    def to_sexp
      [:up, @index, @distance]
    end

  end

end
