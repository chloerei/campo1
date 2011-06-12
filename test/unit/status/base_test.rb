require 'test_helper'

class Status::BaseTest < ActiveSupport::TestCase
  test "should set timestamps" do
    assert_not_nil Factory(:status_base).created_at
    time = Time.now - 1.day
    assert_equal time, Factory(:status_base, :created_at => time).created_at
  end
end
