class Notification::Mention < Notification::Base
  referenced_in :topic
  referenced_in :reply
  referenced_in :user
  field :page, :type => Integer, :default => 1
end
