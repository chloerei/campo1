require 'test_helper'

class ReplyTest < ActiveSupport::TestCase
  def setup
    @user  = Factory :user
    @admin = create_admin
    @topic = Factory(:topic, :user => @user)
  end

  test "should create status after create" do
    reply = Factory :reply
    assert_not_nil Status::Reply.where(:reply_id => reply.id).first
  end

  def test_extract_mentions
    6.times {|n| User.create :username => "user_#{n}", :email => "email_#{n}@test.com", :password => '12345678', :password_confirmation => '12345678'}
    reply = @topic.replies.new :content => "some text @user_0 @user_1 @user_2 @user_3 @user_4 @user_5 @user_6 @user_99 some text"
    reply.user = @user
    assert_equal [], reply.mention_user_ids
    reply.save
    assert_equal 5, reply.mention_user_ids.size

    reply.content = "some text @#{@user.username} some text"
    reply.save
    assert_equal [], reply.mention_user_ids
    reply.content = "some text @#{@admin.username}.com some text"
    reply.save
    assert_equal [], reply.mention_user_ids
    reply.content = "some text @#{@admin.username}a.com some text"
    reply.save
    assert_equal [], reply.mention_user_ids
    reply.content = "some text @#{@admin.username.upcase} some text"
    reply.save
    assert_equal [@admin.id], reply.mention_user_ids

    reply.content = "@#{@admin.username.upcase}~"
    reply.save
    assert_equal [@admin.id], reply.mention_user_ids
  end

  def test_send_mention_notifications
    reply = @topic.replies.new :content => "some text @#{@user.username} @#{@admin.username} some text"
    reply.user = @user
    assert_no_difference "@user.reload.notifications.count" do
      assert_difference "@admin.reload.notifications.count" do
        reply.save
        assert_equal [@admin.id], reply.mention_user_ids
      end
    end
  end

  test "should no send mention if user block" do
    block_user = Factory :user
    @user.block block_user
    @user.reload
    assert_no_difference "@user.reload.notifications.count" do
      assert_difference "@admin.reload.notifications.count" do
        reply = Factory :reply, :content => "@#{@user.username} @#{@admin.username}", :user => block_user
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
