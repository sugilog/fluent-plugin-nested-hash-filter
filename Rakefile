require "bundler/gem_tasks"
require "rake/testtask"

desc "Run tests"
Rake::TestTask.new do |test|
  test.name = :test
  test.libs = ["lib", "test"]
  test.test_files = FileList["test/**/*_test.rb"]
  test.verbose = true
end

task :default => :test
