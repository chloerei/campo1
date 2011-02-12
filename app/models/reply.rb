class Reply
  include Mongoid::Document

  referenced_in :topic
  referenced_in :user
end
