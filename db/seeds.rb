# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

user = User.create :username => 'test', :email => 'test@test.com', :password => '12345678', :password_confirmation => '12345678'

50.times do |n|
  t = user.topics.create :title => "Topic #{n}", :content => "content", :tags => "tag tag2"
  50.times do
    r = Reply.new :content => 'content'
    r.user = user
    r.topic = t
    r.save
  end
end
