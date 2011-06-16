class StreamBuilder
  @queue = :stream_builder

  def self.perform(id)
    User.find(id).stream.rebuild
  end
end
