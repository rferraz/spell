module Storable
  
  def dump
    inspect
  end
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    
    def load(*arguments)
      new(*arguments)
    end
    
  end
  
end