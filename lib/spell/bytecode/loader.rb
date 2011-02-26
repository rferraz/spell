class Loader
  
  def run(dump)
    load(remove_header(dump))
  end
  
  protected
  
  def load(clean_dump)
    clean_dump.lines.inject([]) do |instructions, input|
      name, *parameters = input.strip.split(" ")
      name = name.capitalize + ([:dictionary, :array, :jump].include?(name.to_sym) ? parameters.shift.capitalize : "")
      instructions << Bytecode::const_get(name).load(*parameters)
      instructions
    end
  end
  
  def remove_header(raw_dump)
    raw_dump.sub(Dumper::HEADER, "")
  end
  
end
