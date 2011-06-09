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
      @stream.push_status Factory(:status_base)
    end
  end

  test "push status should have limit" do
    original_limit = Stream.status_limit
    Stream.status_limit = 10
    11.times { @stream.push_status Factory(:status_base) }
    assert_equal 10, @stream.status_ids.count
    Stream.status_limit = original_limit
  end

  test "should fetch status" do
    25.times { @stream.push_status Factory(:status_base) }
    assert_equal 20, @stream.fetch_statuses.count
    assert_equal 5,  @stream.fetch_statuses(:page => 2).count
    assert_equal 10, @stream.fetch_statuses(:per_page => 10, :page => 2).count

    statuses = @stream.fetch_statuses(:per_page => 10, :page => 2)
    assert_equal 10, statuses.per_page
    assert_equal 2,  statuses.current_page
    assert_equal 25, statuses.total_entries
  end
end
