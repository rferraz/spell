class LLVMRunner
  
  def initialize(dump)
    LLVM.init_x86
    @dump = dump
  end
  
  def run(module_wrapper)
    if @dump
      module_wrapper.verified_module.dump 
    else
      LLVM::ExecutionEngine.
        create_jit_compiler(module_wrapper.verified_module).
        run_function(module_wrapper.default_function)
      end
  end
  
end