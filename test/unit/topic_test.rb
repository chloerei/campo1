require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  def setup
    @user = create_user
    @admin = create_admin
    @topic = @user.topics.create :title => 'title', :content => 'content', :tags => 'tag1 tag2'
  end

  def test_close_and_open
    @topic.close!
    assert @topic.closed?
    @topic.open!
    assert !@topic.closed?
  end

  def test_edited_at
    t = @user.topics.new :title => 'title', :content => 'content', :tags => 'tag1 tag2'
    t.save
    assert_nil t.edited_at
    t.content = 'edited'
    t.save
    assert_not_nil t.edited_at
  end

  def test_tags
    t = Topic.new :title => 'title', :content => 'content'
    t.tags = "tag1 tag2 tag3"
    assert_equal ["tag1", "tag2", "tag3"], t.tags

    t.tags = "/"
    assert_equal [], t.tags
    t.tags = "a/b"
    assert_equal ["ab"], t.tags
    t.tags = "a" * 21 + " b"
    assert_equal ["b"], t.tags
    t.tags = "."
    assert_equal [], t.tags
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

  def test_marker
    t = Topic.create :title => 'title', :content => 'content'
    assert_nil t.marker_ids
    t.mark_by @user
    assert_equal [@user.id], t.reload.marker_ids
    t.mark_by @user
    assert_equal [@user.id], t.reload.marker_ids

    # query
    assert Topic.marked_by(@user).include? t

    t.unmark_by @user
    assert_equal [], t.reload.marker_ids
    t.unmark_by @user
    assert_equal [], t.reload.marker_ids
  end

  def test_replier
    t = Topic.create :title => 'title', :content => 'content'
    assert_nil t.replier_ids
    t.reply_by @user
    assert_equal [@user.id], t.reload.replier_ids
    t.reply_by @user
    assert_equal [@user.id], t.reload.replier_ids

    # query
    assert Topic.replied_by(@user).include? t

    # callback
    r = t.replies.new :content => 'content'
    r.user = @admin
    r.save
    assert t.reload.replier_ids.include? @admin.id

    # ignore topic author
    t = Topic.new :title => 'title', :content => 'content'
    t.user = @user
    t.save
    t.reply_by @admin
    assert_equal [@admin.id], t.reload.replier_ids
    t.reply_by @user
    assert_equal [@admin.id], t.reload.replier_ids
  end
end
