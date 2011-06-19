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

  # slow than fetch_statuses, but complete than fetch_statuses
  def statuses
    Status::Base.where(:_id.in => status_ids).desc(:created_at)
  end

  def fetch_statuses(options = {})
    page     = (options[:page] || 1).to_i
    per_page = (options[:per_page] || 20).to_i

    start = (page - 1) * per_page
    stop  = page * per_page - 1

    statuses = Status::Base.where(:_id.in => status_ids(start, stop)).desc(:created_at)
    WillPaginate::Collection.create(page, per_page, status_ids.count) do |pager|
      pager.replace(statuses.to_a)
    end
  end

  def rebuild_later
    Resque.enqueue(StreamBuilder, @user.id)
  end

  def rebuild
    mark_topic_ids = Topic.where(:marker_ids => @user.id).only(:_id).map(&:_id) 
    self_topic_ids = @user.topics.only(:_id).map(&:_id)
    topic_ids = (mark_topic_ids + self_topic_ids).uniq
    status_ids = Status::Base.where(:targeted.ne => true, :user_id.ne => @user.id, :user_id.nin => @user.blocking_ids.to_a).any_of({:user_id.in => @user.following_ids.to_a}, {:tags.in => @user.favorite_tags.to_a}, {:topic_id.in => topic_ids}).asc(:created_at).limit(Stream.status_limit).only(:_id).map(&:id)
    $redis.multi do
      $redis.del store_key
      status_ids.each {|id| $redis.lpush store_key, id }
      $redis.ltrim store_key, 0, Stream.status_limit - 1
    end
  end
end
