Gem::Specification.new do |s|
  s.name = %q{scoped-search}
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["slainer68"]
  s.date = %q{2010-08-04}
  s.description = %q{Easily implement search forms and column ordering based on your models scopes. For Rails 3, compatible with ActiveRecord and Mongoid.}
  s.email = %q{slainer68@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.textile"
  ]
  s.files = [
    ".gitignore",
     "Gemfile",
     "Gemfile.lock",
     "LICENSE",
     "README.textile",
     "Rakefile",
     "VERSION",
     "init.rb",
     "lib/scoped_search.rb",
     "scoped-search.gemspec",
     "spec/scoped_search_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/novagile/scoped-search}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Easily implement search forms and column ordering based on your models scopes}
  s.test_files = [
    "spec/scoped_search_spec.rb",
     "spec/spec_helper.rb"
  ]

  s.add_development_dependency 'rake', '~> 0.8.7'  
  s.add_development_dependency 'rspec', '~> 2.5.0'
  s.add_development_dependency 'rspec-rails', '~> 2.5.0'
  s.add_development_dependency 'rails', '~> 3.0.0'   
  s.add_development_dependency 'sqlite3-ruby'  
  
  s.required_rubygems_version = ">= 1.3.6"
end

