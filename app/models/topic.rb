class Topic
  include Mongoid::Document

  field :title
  field :content
  field :tags, :type => Array

  references_many :replies
  referenced_in :user

  validates_presence_of :title, :content
  validates_length_of :title, :maximum => 100
  validates_length_of :tags, :maximum => 5

  def tags=(str)
    write_attribute :tags, str.split
  end
end
