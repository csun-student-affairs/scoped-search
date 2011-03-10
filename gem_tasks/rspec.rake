require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  # t.rcov = true
  # t.rcov_opts = ['--exclude', 'spec,/usr/lib/ruby,gems', '--rails', '--text-report']
  t.pattern = FileList['spec/**/*_spec.rb']  
  t.rspec_opts = ["--color"]
end