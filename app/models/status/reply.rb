class Status::Reply < Status::Base
  belongs_to :topic
  belongs_to :reply

  after_create :send_stream

  def send_stream
    User.where(:_id.in => target_user_ids).each do |user|
      user.stream.push_status self
    end
  end

  def target_user_ids
    [topic.marker_ids.to_a, topic.replier_ids.to_a, user_id, topic.user_id].flatten.uniq
  end
end
