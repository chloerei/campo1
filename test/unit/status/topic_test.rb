require 'test_helper'

class Status::TopicTest < ActiveSupport::TestCase
  test "should get target user ids" do
    status_topic = Factory :status_topic

    assert status_topic.target_user_ids.empty?
  end

  test "should send stream who create topic" do
    user = Factory :user
    assert_difference "user.stream.status_ids.count" do
      status_topic = Factory :status_topic, :user => user
    end
  end
end
