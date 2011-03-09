require 'test_helper'

class ReplyTest < ActiveSupport::TestCase
  def setup
    @user = create_user
    @topic = Topic.new :title => 'title', :content => 'content'
    @topic.user = @user
    @topic.save
  end

  def test_extract_memtions
    6.times {|n| User.create :username => "user_#{n}", :email => "email_#{n}@test.com", :password => '12345678', :password_confirmation => '12345678'}
    reply = @topic.replies.new :content => "some text @user_0 @user_1 @user_2 @user_3 @user_4 @user_5 @user_6 @user_99 some text"
    assert_equal nil, reply.memtion_user_ids
    reply.save
    assert_equal 5, reply.memtion_user_ids.size
  end

  def test_update_topic_replies_cache_field
    reply = Reply.new :content => 'content'
    reply.user = @user
    assert_difference "@topic.replies_count.to_i" do
      @topic.replies << reply
      assert reply.valid?
    end
    assert_equal @user, @topic.last_replied_by
    assert_equal reply.created_at, @topic.actived_at

    assert_difference "@topic.replies_count.to_i", -1 do
      reply.destroy
    end
  end
end
