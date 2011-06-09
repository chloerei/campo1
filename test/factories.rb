Factory.define :user do |user|
  user.sequence(:username) {|n| "user_#{n}"}
  user.sequence(:email) {|n| "user#{n}@local.me"}
  user.password 'password'
  user.password_confirmation 'password'
end

Factory.define :topic do |topic|
  topic.title 'title'
  topic.content 'content'
  topic.association :user
end

Factory.define :reply do |reply|
  reply.content 'content'
  reply.association :user
  reply.association :topic
end

Factory.define :status_base, :class => Status::Base do |s|
  s.association :user
end

Factory.define :status_reply, :class => Status::Reply do |s|
  s.association :user
  s.association :topic
  s.association :reply
end

Factory.define :status_topic, :class => Status::Topic do |s|
  s.association :user
  s.association :topic
end
