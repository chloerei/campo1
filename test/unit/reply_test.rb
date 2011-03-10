require 'test_helper'

class ReplyTest < ActiveSupport::TestCase
  def setup
    @user = create_user
    @admin = create_admin
    @topic = Topic.new :title => 'title', :content => 'content'
    @topic.user = @user
    @topic.save
  end

  def test_extract_memtions
    6.times {|n| User.create :username => "user_#{n}", :email => "email_#{n}@test.com", :password => '12345678', :password_confirmation => '12345678'}
    reply = @topic.replies.new :content => "some text @user_0 @user_1 @user_2 @user_3 @user_4 @user_5 @user_6 @user_99 some text"
    reply.user = @user
    assert_equal [], reply.memtion_user_ids
    reply.save
    assert_equal 5, reply.memtion_user_ids.size

    reply.content = "some text @#{@user.username} some text"
    reply.save
    assert_equal [], reply.memtion_user_ids
    reply.content = "some text @#{@admin.username}.com some text"
    reply.save
    assert_equal [], reply.memtion_user_ids
  end

  def test_send_memtion_notifications
    reply = @topic.replies.new :content => "some text @#{@user.username} @#{@admin.username} some text"
    reply.user = @user
    assert_no_difference "@user.reload.notifications.count" do
      assert_difference "@admin.reload.notifications.count" do
        reply.save
        assert_equal [@admin.id], reply.memtion_user_ids
      end
    end
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
