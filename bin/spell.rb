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
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end    
  end.parse!

require "spell"

def primitives
  {
    "show" => lambda { |value| print value ; value },
    "range" => lambda { |bottom, top| bottom <= top ? (bottom..top).to_a : (top..bottom).to_a.reverse },
    "string" => lambda { |value| value.to_s },
    "null" => lambda { |list| list.empty? },
    "head" => lambda { |list| list.first },
    "tail" => lambda { |list| first, *rest = list ; rest },
    ":" => lambda { |element, list| list.unshift(element) ; list },
    "math#sqrt" => Math.method(:sqrt),
    "compare" => lambda { |a, b| a < b ? "lt" : a > b ? "gt" : "eq" },
    "assert" => lambda { |v, m| v || raise(m) }
  }
end

def run
  interpreter = Interpreter.new(ARGF.read,
                                $options[:debug],
                                Dir[File.join(File.dirname(__FILE__), "..", "stdlib")])
  interpreter.attach_primitives(primitives)
  interpreter.send($options[:dump] ? :dump : :run)
end

if $0 == __FILE__
  run
end
