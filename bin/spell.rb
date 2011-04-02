#! /usr/bin/env ruby

$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "lib")

require 'optparse'

  $options = {}
  
  OptionParser.new do |opts|
    opts.banner = "Usage: spell.rb [options] FILENAME"
    opts.on("-D", "--debug", "Print debug information when running") do |v|
      $options[:debug] = true
    end
    opts.on("-d", "--dump", "Dump bytecode") do |d|
      $options[:dump] = d
    end
    opts.on("-m", "--mode [MODE]", [:interpret, :jit, :compile], "Execution mode (interpret, jit, compile)") do |m|
      $options[:mode] = m || :interpret
    end    
    opts.on("-o", "--output FILENAME", "If compiling, the name of the generated executable file") do |f|
      $options[:filename] = f || "a.out"
    end
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end    
  end.parse!

require "tmpdir"
require "spell"

def run
  LLVMConfig.use_gc = $options[:mode] == :compile
  if $options[:mode] == :interpret 
    engine_options = [ARGF.read, $options[:debug], Dir[File.join(File.dirname(__FILE__), "..", "stdlib")]]
    command = $options[:dump] ? :dump : :run
    create_interpreter(*engine_options).send(command)
  else
    engine_options = [ARGF.read, $options[:debug], $options[:filename], Dir[File.join(File.dirname(__FILE__), "..", "stdlib")]]
    command = $options[:dump] ? :dump : ($options[:mode] == :compile ? :compile : :run)
    create_compiler(*engine_options).send(command)
  end
end

def create_interpreter(code, debug, stdlib_path)
  Interpreter.new(code, debug, stdlib_path)
end

def create_compiler(code, debug, output_filename, stdlib_path)
  Compiler.new(code, debug, output_filename, stdlib_path)
end

if $0 == __FILE__
  run
end
