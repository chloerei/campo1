require 'test_helper'

class StreamTest < ActiveSupport::TestCase
  def setup
    @user = Factory :user
    @stream = @user.stream
  end

  test "should init from user" do
    assert_not_nil @stream
    assert_equal @user, @stream.user
  end

  test "should get store key" do
    assert_equal "stream:#{@user.id}", @stream.store_key
  end

  test "should get status_ids" do
    assert_equal [], @stream.status_ids
  end

  test "should push status" do
    assert_difference "@stream.status_ids.count" do
      @stream.push_status Status::Base.create
    end
  end

  test "push status should have limit" do
    Stream.status_limit = 10
    11.times { @stream.push_status Status::Base.create }
    assert_equal 10, @stream.status_ids.count
  end
end
