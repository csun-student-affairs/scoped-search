source :rubygems

gem 'ruby-debug', :platform => :ruby_18
gem 'ruby-debug19', :platform => :ruby_19

case ENV['ORM']
when nil, 'active_record', 'AR'
  # nothing specific to do
when 'mongoid'
  gem 'mongoid', '2.0.0.beta.20'
else
  raise "Unknown ORM: #{ENV['ORM']}"
end
  
gemspec