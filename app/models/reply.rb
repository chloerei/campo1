class Reply
  include Mongoid::Document

  field :content

  referenced_in :topic
  referenced_in :user

  validates_presence_of :content
end
