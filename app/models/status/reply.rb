class Status::Reply < Status::Base
  belongs_to :topic
  belongs_to :reply
end
