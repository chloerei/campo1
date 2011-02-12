class Topic
  include Mongoid::Document

  references_many :replies
  referenced_in :user
end
