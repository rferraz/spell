class Dumper
  
  HEADER = "SPELL\n\n"
  
  def run(instructions)
    HEADER + instructions.collect(&:dump).join("\n")
  end
  
end
