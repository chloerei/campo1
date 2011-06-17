Resque.redis = Redis.new(:host => 'localhost', :port => 6379, :db => 1)
Resque.inline = ENV['RAILS_ENV'] == "test"
