class Status::Reply < Status::Base
  belongs_to :topic
  belongs_to :reply
  validates_presence_of :topic_id, :reply_id

  def target_user_ids
    [topic.marker_ids.to_a, topic.user_id, user.follower_ids].flatten.uniq - [user_id]
  end
end
