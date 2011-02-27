class Topic
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title
  field :content
  field :tags, :type => Array
  field :marker_ids, :type => Array

  scope :marked_by, lambda { |user| where(:marker_ids => user.id) }

  references_many :replies, :validate => false, :dependent => :delete
  referenced_in :user
  referenced_in :last_replied_by, :class_name => 'User'
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

  def set_edited_at
    self.edited_at = Time.now.utc
  end

  def tags=(value)
    if value.is_a? String
      tags = value.downcase.split.delete_if {|tag| tag.size > 20}
      write_attribute :tags, tags.uniq
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
    collection.update({:_id => self.id, :marker_ids => {"$ne" => user.id}},
                      {"$push" => {:marker_ids => user.id}})
  end

  def unmark_by(user)
    collection.update({:_id => self.id},
                      {"$pull" => {:marker_ids => user.id}})
  end
end
