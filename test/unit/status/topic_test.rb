require 'test_helper'

class Status::TopicTest < ActiveSupport::TestCase
  test "should get target user ids" do
    status_topic = Factory :status_topic

    assert status_topic.target_user_ids.empty?
    user = Factory :user
    status_topic.user.add_follower user
    status_topic.user.reload
    assert status_topic.target_user_ids.include? user.id
  end

  test "should no send stream to whom create topic" do
    user = Factory :user
    assert_no_difference "user.stream.status_ids.count" do
      status_topic = Factory :status_topic, :user => user
    end
  end

  test "should send stream to whom follow user who create topic" do
    user = Factory :user
    user_two = Factory :user
    user.add_follower user_two
    user.reload
    assert_difference "user_two.stream.status_ids.count" do
      Factory :status_topic, :user => user
    end
  end
end
