class Status::Topic < Status::Base
  field :tags, :type => Array
  belongs_to :topic
  validates_presence_of :topic_id

  def target_user_ids
    [user.follower_ids.to_a, User.where(:favorite_tags.in => topic.tags.to_a).only(:_id).map(&:id)].flatten.uniq - [user_id] - user.blocker_ids.to_a
  end
end
