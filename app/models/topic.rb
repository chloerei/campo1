class Topic
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title
  field :content
  field :tags, :type => Array

  references_many :replies, :validate => false
  referenced_in :user
  referenced_in :last_replied_by, :class_name => 'User'
  field :actived_at, :type => Time
  field :replies_count, :type => Integer, :default => 0

  validates_presence_of :title, :content
  validates_length_of :title, :maximum => 100
  validates_length_of :tags, :maximum => 5

  attr_accessible :title, :content, :tags

  before_create :set_actived_at

  def tags=(value)
    if value.is_a? String
      write_attribute :tags, value.split if !value.empty?
    elsif value.is_a? Array
      write_attribute :tags, value if !value.empty?
    end
  end

  def tags_string
    return tags.join(' ') unless tags.blank?
  end

  def set_actived_at
    self.actived_at = Time.now.utc
  end
end
