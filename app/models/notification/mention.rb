class Notification::Mention < Notification::Base
  referenced_in :topic
  referenced_in :reply
  referenced_in :user
end
