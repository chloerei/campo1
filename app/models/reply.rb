class Reply
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content

  referenced_in :topic
  referenced_in :user

  validates_presence_of :content

  attr_accessible :content
end
