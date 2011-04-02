class LLVMCompiler
  
  def initialize(filename)
    @filename = filename || "a.out"
  end
  
  def run(module_wrapper)
    gc = File.expand_path(File.join(__FILE__, "..", "..", "..", "..", "runtime", "bdw-gc.c"))
    bc_filename = File.join(Dir.tmpdir, "spell." + rand.to_s + ".bc")
    module_wrapper.verified_module.write_to(bc_filename)
    system "llvmc -v -lgc #{gc} #{bc_filename} -o #{@filename}"
  end
  
end