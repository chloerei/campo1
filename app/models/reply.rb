class Reply
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content

  referenced_in :topic
  referenced_in :user

  validates_presence_of :content

  attr_accessible :content

  after_create :increment_topic_reply_cache
  after_destroy :decrement_topic_reply_cache

  def increment_topic_reply_cache
    topic.last_replied_by = user
    topic.last_replied_at = created_at
    topic.save
    topic.inc :replies_count, 1
  end

  def decrement_topic_reply_cache
    # ignore user and time cache
    topic.inc :replies_count, -1
  end
end
