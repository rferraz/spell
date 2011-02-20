#! /usr/bin/env ruby

$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "lib")

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
    "compare" => lambda { |a, b| a < b ? "lt" : a > b ? "gt" : "eq" }
  }
end

def run
  interpreter = Interpreter.new(ARGF.read,
                                ENV["DEBUG"],
                                Dir[File.join(File.dirname(__FILE__), "..", "stdlib")])
  interpreter.attach_primitives(primitives)
  interpreter.run
end

if $0 == __FILE__
  run
end
