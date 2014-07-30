require 'rake/testtask'
require 'yaml'

Rake::TestTask.new do |t|
  t.libs << 'test'
  #t.test_files = FileList['test/test*.rb', 'test/cedilla/test_*.rb']
  t.test_files = FileList['test/cedilla/test_citation.rb']
end

desc "Run tests"
task :default => :test
