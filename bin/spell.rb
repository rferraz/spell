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
  primitives = {
      "show" => lambda { |value| print value ; value },
      "range" => lambda { |bottom, top| bottom <= top ? (bottom..top).to_a : (top..bottom).to_a.reverse },
      "to#string" => lambda { |value| value.to_s },
      "empty" => lambda { |list| list.empty? },
      "head" => lambda { |list| list.first },
      "tail" => lambda { |list| first, *rest = list ; rest },
      ":" => lambda { |element, list| list.unshift(element) ; list },
      "reverse" => lambda { |list| list.reverse },
      "math#sqrt" => Math.method(:sqrt),
      "compare" => lambda { |a, b| a < b ? "lt" : a > b ? "gt" : "eq" },
      "assert" => lambda { |v, m| v || raise(m) }
  }
  interpreter = Interpreter.new(code, debug, stdlib_path)
  interpreter.attach_primitives(primitives)
  interpreter
end

def create_compiler(code, debug, stdlib_path)
  Compiler.new(code, debug, stdlib_path)
end

if $0 == __FILE__
  run
end
