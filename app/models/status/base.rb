class Status::Base
  include Mongoid::Document

  belongs_to :user
  validates_presence_of :user_id

  after_create :send_stream

  def send_stream
    user.stream.push_status self
    send_stream_to_target_users
  end

  def send_stream_to_target_users
    if target_user_ids.any?
      User.where(:_id.in => target_user_ids).each do |user|
        user.stream.push_status self
      end
    end
  end

  def target_user_ids
    []
  end
end
