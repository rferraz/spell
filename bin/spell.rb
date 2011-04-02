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
    opts.on("-j", "--jit", "Use LLVM") do |j|
      $options[:jit] = j
    end    
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end    
  end.parse!

require "spell"

def run
  options = [ARGF.read, $options[:debug], Dir[File.join(File.dirname(__FILE__), "..", "stdlib")]]
  engine = $options[:jit] ? create_compiler(*options) : create_interpreter(*options)
  engine.send($options[:dump] ? :dump : :run)
end

def create_interpreter(code, debug, stdlib_path)
  Interpreter.new(code, debug, stdlib_path)
end

def create_compiler(code, debug, stdlib_path)
  Compiler.new(code, debug, stdlib_path)
end

if $0 == __FILE__
  run
end
