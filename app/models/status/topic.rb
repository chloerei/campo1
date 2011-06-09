class Status::Topic < Status::Base
  belongs_to :topic
  validates_presence_of :topic_id

  def target_user_ids
    user.follower_ids.to_a - [user_id]
  end
end
