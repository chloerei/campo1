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
    topic.replies_count ||= 0
    topic.replies_count += 1
    topic.save
  end

  def decrement_topic_reply_cache
    topic.last_replied_by = nil
    topic.last_replied_at = nil
    topic.replies_count -= 1
    topic.replies_count = nil if topic.replies_count == 0
    topic.save
  end
end
