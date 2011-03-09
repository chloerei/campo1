class Notification::Base
  include Mongoid::Document

  field :text

  embedded_in :user, :inverse_of => :notifications
end
