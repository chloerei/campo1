class Topic
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title
  field :content
  field :tags, :type => Array

  references_many :replies
  referenced_in :user
  referenced_in :last_replied_by, :class_name => 'User'
  field :last_replied_at, :type => Time
  field :replies_count, :type => Integer

  validates_presence_of :title, :content
  validates_length_of :title, :maximum => 100
  validates_length_of :tags, :maximum => 5

  attr_accessible :title, :content, :tags

  def tags=(str)
    write_attribute :tags, str.split
  end
end
