require 'rake/rdoctask'
require 'rake/testtask'
require 'rcov/rcovtask'

Rake::RDocTask.new do |t|
  t.rdoc_files   = Dir['lib/**/*.rb']
end

Rcov::RcovTask.new do |t|
  t.libs << "test"
  t.rcov_opts << "--exclude gems"
  t.test_files = FileList["test/**/*_test.rb"]
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => [:test]