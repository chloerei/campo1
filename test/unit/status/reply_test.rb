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
    assert status_reply.target_user_ids.include?(replier.id)
  end

  test "should send stream who create reply" do
    user = Factory :user

    assert_difference "user.stream.status_ids.count" do
      Factory :status_reply, :user => user
    end
  end

  test "should send stream who marked topic after create reply" do
    topic   = Factory :topic
    replier = Factory :user
    marker  = Factory :user
    topic.reply_by replier
    topic.mark_by marker
    topic.reload

    assert_difference "marker.stream.status_ids.count" do
      assert_difference "replier.stream.status_ids.count" do
        assert_difference "topic.user.stream.status_ids.count" do
          Factory :status_reply, :topic => topic
        end
      end
    end
  end
end
