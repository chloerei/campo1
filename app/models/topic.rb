class Topic
  include Mongoid::Document
  include Mongoid::Timestamps
  include TagParser

  field :title
  field :content
  field :tags, :type => Array
  field :marker_ids, :type => Array
  field :muter_ids, :type => Array
  field :replier_ids, :type => Array
  field :closed, :type => Boolean

  scope :marked_by, lambda { |user| where(:marker_ids => user.id) }
  scope :replied_by, lambda { |user| where(:replier_ids => user.id) }
  scope :interesting_by, lambda {|user|
    where(:muter_ids.ne => user.id, :user_id.nin => user.blocking_ids.to_a).any_of({:tags.in => user.favorite_tags.to_a}, {:user_id.in => user.following_ids.to_a})
  }

  has_many :replies, :validate => false, :dependent => :destroy
  has_many :statuses, :validate => false, :class_name => 'Status::Base', :dependent => :delete
  belongs_to :user
  belongs_to :last_replied_by, :class_name => 'User'
  field :actived_at, :type => Time
  field :replies_count, :type => Integer, :default => 0
  field :edited_at, :type => Time

  validates_presence_of :title, :content
  validates_length_of :title, :maximum => 100
  validates_length_of :tags, :maximum => 5

  attr_accessible :title, :content, :tags

  before_create :set_actived_at
  before_update :set_edited_at, :if => Proc.new { |topic| 
    topic.title_changed? || topic.content_changed? || topic.tags_changed?
  }
  after_create :create_status

  def self.create_topic_hash(topic_ids)
    topic_hash = {}
    topics = Topic.where(:_id.in => topic_ids)
    topics.each{|topic| topic_hash[topic.id] = topic}
    topic_hash
  end

  def last_anchor
    replies_count == 0 ? nil : "replies-#{replies_count}"
  end

  def last_page
    replies_count == 0 ? 1 : (replies_count / 20.to_f).ceil
  end

  def close!
    self.closed = true
    save
  end

  def open!
    self.closed = false
    save
  end

  def set_edited_at
    self.edited_at = Time.now.utc
  end

  def tags=(value)
    if value.is_a? String
      write_attribute :tags, parse_tags_from_string(value)
    else
      write_attribute :tags, value.uniq
    end
  end

  def tags_string
    return tags.join(' ') unless tags.blank?
  end

  def set_actived_at
    self.actived_at = Time.now.utc
  end

  def mark_by(user)
    collection.update({:_id => self.id},
                      {"$addToSet" => {:marker_ids => user.id}})
    user.stream.rebuild_later
  end

  def unmark_by(user)
    collection.update({:_id => self.id},
                      {"$pull" => {:marker_ids => user.id}})
    user.stream.rebuild_later
  end
  
  def mute_by(user)
    collection.update({:_id => self.id},
                      {"$addToSet" => {:muter_ids => user.id}})
    user.stream.rebuild_later
  end

  def unmute_by(user)
    collection.update({:_id => self.id},
                      {"$pull" => {:muter_ids => user.id}})
    user.stream.rebuild_later
  end

  def reply_by(user)
    return if self.user_id == user.id
    collection.update({:_id => self.id, :replier_ids => {"$ne" => user.id}},
                      {"$push" => {:replier_ids => user.id}})
  end

  def create_status(options = {})
    Status::Topic.create :user       => user,
                         :topic      => self,
                         :created_at => created_at,
                         :silent     => options[:silent],
                         :tags       => tags
  end
end
