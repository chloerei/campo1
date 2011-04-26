class Notification::Mention < Notification::Base
  belongs_to :topic
  belongs_to :reply
  belongs_to :reply_user, :class_name => 'User'
end
