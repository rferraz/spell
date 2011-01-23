module Ast

  class Statement

    def initialize(name, arguments, body)
      @name, @arguments, @body = name, arguments, body
    end

    def to_sexp
      [:define, @name] +
        (@arguments.empty? ? [] : [[:arguments] + @arguments]) +
        [@body.to_sexp]
    end

  end

end
