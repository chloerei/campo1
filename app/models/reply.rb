class Reply
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content
  field :memtion_user_ids, :type => Array

  references_and_referenced_in_many :memtion_users, :class_name => 'User', :validate => false
  referenced_in :topic
  referenced_in :user

  validates_presence_of :content

  attr_accessible :content

  after_create :increment_topic_reply_cache
  after_destroy :decrement_topic_reply_cache
  before_save :extract_memtions
  after_create :send_memetion_notifications

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
    usernames = self.content.to_s.scan(/@([A-Za-z0-9_]{3,20})\s/).flatten.uniq.delete_if{|username| username == self.user.username}.slice(0..4)
    if usernames.blank?
      self.memtion_user_ids = []
    else
      self.memtion_user_ids = User.where(:username.in => usernames).only(:_id).map(&:_id)
    end
  end

  def send_memetion_notifications
    memtion_users.each do |user|
      user.send_notification({:reply_user_id  => self.user_id,
                              :topic_id => self.topic_id,
                              :reply_id => self.id,
                              :text     => self.content.slice(0..99)}, Notification::Mention)
    end
  end
end
