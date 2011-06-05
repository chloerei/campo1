class Stream
  attr_accessor :user

  cattr_accessor :status_limit
  self.status_limit = 800

  def initialize(user)
    @user = user
  end

  def store_key
    "stream:#{@user.id}"
  end

  def status_ids(start = 0, stop = -1)
    $redis.lrange store_key, start, stop
  end

  def push_status(status)
    $redis.lpush store_key, status.id
    $redis.ltrim store_key, 0, Stream.status_limit - 1
  end
end
