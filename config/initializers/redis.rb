$redis = Redis.new(:host => 'localhost', :port => 6379)
$redis.select(15) if ENV["RAILS_ENV"] == 'test' # avoid flushdb in test mode
