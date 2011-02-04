class Analyser

  def initialize(ast)
    @ast = ast
  end

  def analyse
    reset_scopes
    reset_methods_table
  end

  def self.analyze(ast)
    new(ast).analyse
  end

  private

  def reset_scopes
    @scopes = [Scope.new]
  end

  def reset_methods_table
    @methods = []
  end

end
