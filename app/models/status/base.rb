class Status::Base
  include Mongoid::Document

  belongs_to :user
end
