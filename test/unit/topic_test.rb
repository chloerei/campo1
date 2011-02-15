require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  def test_tags
    t = Topic.new :title => 'title', :content => 'content'
    t.tags = "tag1 tag2 tag3"
    assert_equal ["tag1", "tag2", "tag3"], t.tags
  end

  def test_tags_length
    t = Topic.new :title => 'title', :content => 'content'
    assert t.valid?
    t.tags = "tag1 tag2 tag3 tag4 tag5"
    assert t.valid?
    t.tags = "tag1 tag2 tag3 tag4 tag5 tag6"
    assert !t.valid?

    t.tags = "a" * 21
    assert_equal [], t.tags
  end

  def test_set_actived_at_before_create
    t = Topic.new :title => 'title', :content => 'content'
    t.save
    assert_not_nil t.actived_at
  end
end
