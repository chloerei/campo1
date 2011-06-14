class Status::Base
  include Mongoid::Document
  field :created_at

  attr_accessor :silent

  belongs_to :user
  validates_presence_of :user_id

  after_create :send_stream
  before_create :set_timestamps

  def set_timestamps
    self.created_at ||= Time.now
  end

  def send_stream
    unless silent
      Resque.enqueue(Status::Deliver, self.id)
    end
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
