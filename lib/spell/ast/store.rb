module Ast

  class Store

    def initialize(type, index, body)
      @type, @index, @body = type, index, body
    end

    def to_sexp
      [:store, @type, @index, @body.to_sexp]
    end

  end

end
