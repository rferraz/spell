module Bytecode

  class Push
    
    include Storable

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def inspect
      "push #{@value || :nothing}"
    end

    def dump
      if @value
        "push #{@value.is_a?(Integer) ? "integer" : "string"} #{@value.to_s.gsub("\n", "\\n")}"
      else
        "push nothing"
      end
    end
    
    def self.load(literal_type, *value)
      if literal_type == "nothing"
        new(nil)        
      else
        new(literal_type == "integer" ? value.first.to_i : value.join(" ").gsub("\\n", "\n"))
      end
    end

  end

end
