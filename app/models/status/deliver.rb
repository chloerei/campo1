class Status::Deliver
  @queue = :status_deliver

  def self.perform(id)
    Status::Base.find(id).send_stream_to_target_users
  end
end
