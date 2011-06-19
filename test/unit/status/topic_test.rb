require 'test_helper'

class Status::TopicTest < ActiveSupport::TestCase
  test "should get target user ids" do
    status_topic = Factory :status_topic

    assert status_topic.target_user_ids.empty?
    user = Factory :user
    user.follow status_topic.user
    status_topic.user.reload
    assert status_topic.target_user_ids.include? user.id

    tag_user = Factory :user, :favorite_tags => ['tag']
    status_topic.topic.tags = ['tag']
    status_topic.topic.save
    assert status_topic.target_user_ids.include? tag_user.id

    tag_user.block status_topic.user
    status_topic.user.reload
    assert !status_topic.target_user_ids.include?(tag_user.id)
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
    user_two.follow user
    user.reload
    assert_difference "user_two.stream.status_ids.count" do
      Factory :status_topic, :user => user
    end
  end
end
