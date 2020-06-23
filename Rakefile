require "bundler/gem_tasks"
require 'yard'

desc "Test the things"
require 'vault-test-tools/rake_task'

desc "Doc the things"
YARD::Rake::YardocTask.new

$VERBOSE=nil

desc "Create test databases and run the test suite"
task :default => [:test]


