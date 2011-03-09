class Notification::Base
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text

  embedded_in :user, :inverse_of => :notifications
end
