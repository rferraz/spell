module Import

  def build
    Parser.parse(File.read(real_file_name(file.text_value)))
  end

  private

  def real_file_name(name)
    (["."] + self.class.spell_root_paths).each do |path|
      real_name = File.join(path, name[1, name.length - 2] + SPELL_EXTENSION)
      return real_name if File.exist?(real_name)
    end

  end

end
