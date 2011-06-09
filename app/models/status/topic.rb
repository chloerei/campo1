class Status::Topic < Status::Base
  belongs_to :topic
  validates_presence_of :topic_id

  def target_user_ids # TODO should return user follower ids
    @target_user_ids ||= [] - [user_id]
    @target_user_ids
  end
end
