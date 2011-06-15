require 'test_helper'

class Status::ReplyTest < ActiveSupport::TestCase
  test "should get target user ids" do
    status_reply = Factory :status_reply

    # exclude source user id
    assert !status_reply.target_user_ids.include?(status_reply.user_id)
    assert status_reply.target_user_ids.include?(status_reply.topic.user_id)

    marker = Factory :user
    status_reply.topic.mark_by marker
    status_reply.topic.reload
    assert status_reply.target_user_ids.include?(marker.id)

    replier = Factory :user
    status_reply.topic.reply_by replier
    status_reply.topic.reload
    assert !status_reply.target_user_ids.include?(replier.id)

    follower = Factory :user
    status_reply.user.add_follower follower
    status_reply.user.reload
    assert status_reply.target_user_ids.include?(follower.id)
  end

  test "should no send if reply is targeted" do
    status_reply = Factory :status_reply
    assert !status_reply.targeted?
    status_reply.reply.content = '@user'
    status_reply.reply.save
    assert !status_reply.targeted?

    user = Factory :user
    status_reply.reply.content = "@#{user.username}"
    status_reply.reply.save
    assert status_reply.targeted?

    assert status_reply.target_user_ids.empty?
    status_reply.topic.mark_by Factory(:user)
    status_reply.topic.reply_by Factory(:user)
    status_reply.topic.reload
    status_reply.user.add_follower Factory(:user)
    status_reply.user.reload
    assert status_reply.target_user_ids.empty?
  end

  test "should no send stream to whom create reply" do
    user = Factory :user

    assert_no_difference "user.stream.status_ids.count" do
      Factory :status_reply, :user => user
    end
  end

  test "should send stream to whom marked topic after create reply" do
    topic   = Factory :topic
    replier = Factory :user
    marker  = Factory :user
    topic.reply_by replier
    topic.mark_by marker
    topic.reload

    assert_difference "marker.stream.status_ids.count" do
      assert_no_difference "replier.stream.status_ids.count" do
        assert_difference "topic.user.stream.status_ids.count" do
          Factory :status_reply, :topic => topic
        end
      end
    end
  end
end
