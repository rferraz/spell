module Ast

  class Store
    
    attr_reader :type
    attr_reader :index
    attr_reader :body

    def initialize(type, index, body)
      @type, @index, @body = type, index, body
    end

    def to_sexp
      [:store, @type, @index, @body.to_sexp]
    end

  end

end
