class PassManager
  
  def initialize
    @passes = []
  end
  
  def chain(pass, *config)
    @passes << pass.new(*config)
    self
  end
  
  def run(input)
    @passes.inject(input) do |next_input, pass|
      pass.run(next_input)
    end
  end
  
  def self.chain(pass, *config)
    PassManager.new.chain(pass, *config)
  end
  
end