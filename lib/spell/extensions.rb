class String

  def demodulize
    self.to_s.gsub(/^.*::/, '')
  end

  def underscore
    self.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
  
  def starts_with?(prefix)
    self[0, prefix.length] == prefix
  end
  
end
