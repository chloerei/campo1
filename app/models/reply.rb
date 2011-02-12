class Reply
  include Mongoid::Document

  field :content

  referenced_in :topic
  referenced_in :user

  validates_presence_of :content

  attr_accessible :content
end
