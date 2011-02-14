module Import

  def build
    Parser.parse(File.read(real_file_name(file.text_value)))
  end

  private

  def real_file_name(name)
    File.join(self.class.spell_root_path, name[1, name.length - 2] + SPELL_EXTENSION)
  end

end
