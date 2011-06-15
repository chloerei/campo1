class Status::Reply < Status::Base
  belongs_to :topic
  belongs_to :reply
  validates_presence_of :topic_id, :reply_id

  def target_user_ids
    unless targeted?
      [topic.marker_ids.to_a, topic.user_id, user.follower_ids].flatten.uniq - [user_id]
    else
      []
    end
  end

  def targeted?
    reply.mention_user_ids.any? and reply.content[0] == '@'
  end
end
