class Reply
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content
  field :memtion_user_ids, :type => Array

  referenced_in :topic
  referenced_in :user

  validates_presence_of :content

  attr_accessible :content

  after_create :increment_topic_reply_cache
  after_destroy :decrement_topic_reply_cache
  before_save :extract_memtions

  def increment_topic_reply_cache
    topic.last_replied_by = user
    topic.actived_at = created_at
    topic.save
    topic.inc :replies_count, 1
  end

  def decrement_topic_reply_cache
    # ignore user and time cache
    topic.inc :replies_count, -1
  end

  def extract_memtions
    usernames = self.content.to_s.scan(/@([A-Za-z0-9_]{3,20})/).flatten!
    self.memtion_user_ids = User.where(:username.in => usernames.uniq.slice(0..4)).only(:_id).map(&:_id) unless usernames.blank?
  end
end
