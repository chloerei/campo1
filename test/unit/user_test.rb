require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = create_user
    @admin = create_admin
  end

  def test_send_notification
    n1 = nil
    assert_difference "@user.notifications.count" do
      n1 = @user.send_notification({})
    end
    assert @user.notifications.last.is_a?(Notification::Base)
    n2 = nil
    assert_difference "@user.notifications.count" do
      n2 = @user.send_notification({}, Notification::Mention)
    end
    assert @user.notifications.last.is_a?(Notification::Mention)

    assert @user.notifications.include?(n1)
    assert @user.notifications.include?(n2)
    50.times { @user.send_notification({}) }
    assert_equal 50, @user.reload.notifications.size
    assert !@user.notifications.include?(n1)
    assert !@user.notifications.include?(n2)
  end

  def test_admin
    assert !@user.admin?
    assert @admin.admin?
  end

  def test_ban
    @user.ban!
    assert @user.banned?
    @user.unban!
    assert !@user.banned?
  end

  def test_clean
    make_content
    assert_difference "Topic.count", -1 do
      assert_difference "Reply.count", -3 do
        @user.clean!
      end
    end
  end

  def test_destroy
    make_content
    assert_difference "Topic.count", -1 do
      assert_difference "Reply.count", -3 do
        @user.destroy
      end
    end
  end

  def make_content
    t = @user.topics.create :title => 'title', :content => 'content', :tags => 'tag1 tag2'
    r = t.replies.new :content => 'content'
    r.user = @admin
    r.save
    r = t.replies.new :content => 'content'
    r.user = @user
    r.save

    t = @admin.topics.create :title => 'title', :content => 'content', :tags => 'tag1 tag2'
    r = t.replies.new :content => 'content'
    r.user = @admin
    r.save
    r = t.replies.new :content => 'content'
    r.user = @user
    r.save
  end

  def test_remember_token
    assert_nil @user.remember_token
    assert_nil @user.remember_token_expires_at
    @user.remember_me
    assert_not_nil @user.remember_token
    assert_not_nil @user.remember_token_expires_at

    old_token = @user.remember_token
    @user.remember_me
    assert_not_equal old_token, @user.remember_token

    assert @user.remember_token?
    @user.remember_token_expires_at = Time.now - 1
    @user.save
    assert !@user.remember_token?

    @user.forget_me
    assert_nil @user.remember_token
    assert_nil @user.remember_token_expires_at
  end

  def test_auto_create_profile
    assert_not_nil @user.profile
    assert_equal @user.username, @user.profile.name
  end

  def test_login_sensitive
    user = User.new :username => @user.username.upcase, :email => 'test2@test.com', :password => '12345678', :password_confirmation => '12345678'
    assert !user.valid?, user.errors.to_s
    assert_equal @user, User.authenticate(@user.username.upcase, '12345678')
    assert_equal @user, User.authenticate(@user.email.upcase, '12345678')
  end

  def test_create_user
    assert_not_nil @user.crypted_password
    assert_not_nil @user.password_salt
  end

  def test_new_record_password_valid
    user = User.new :username => 'name2', :email => 'test2@test.com', :password => '', :password_confirmation => ''
    assert !user.valid?, user.errors.to_s
    user.update_attributes :password => '1', :password_confirmation => '1'
    assert !user.valid?, user.errors.to_s
    user.update_attributes :password => '12345678', :password_confirmation => '123456789'
    assert !user.valid?, user.errors.to_s
  end

  def test_authenticate
    assert_equal @user, User.authenticate('test', '12345678')
    assert_equal @user, User.authenticate('test@test.com', '12345678')
  end

  def test_old_record_password_valid
    # can not change password without current password
    assert !@user.update_attributes(:password => '11111111', :password_confirmation => '11111111')
    assert_equal @user, User.authenticate('test', '12345678')

    assert !@user.update_attributes(:password => '11111111', :password_confirmation => '22222222', :current_password => '12345678')
    assert_equal @user, User.authenticate('test', '12345678')

    assert !@user.update_attributes(:password => '11111111', :password_confirmation => '', :current_password => '12345678')
    assert_equal @user, User.authenticate('test', '12345678')

    # ignore confirmation
    assert @user.update_attributes(:password => '', :password_confirmation => '11111111', :current_password => '12345678'), @user.errors.to_s
    assert_equal @user, User.authenticate('test', '12345678')

    assert @user.update_attributes(:password => '11111111', :password_confirmation => '11111111', :current_password => '12345678')
    assert_equal @user, User.authenticate('test', '11111111')
  end

  def test_add_favorite_tags_and_remove_tags
    assert_nil @user.favorite_tags
    @user.add_favorite_tags "tag1 tag2"
    assert_equal ["tag1", "tag2"].sort, @user.favorite_tags.sort
    @user.add_favorite_tags "tag1"
    assert_equal ["tag1", "tag2"].sort, @user.favorite_tags.sort
    @user.add_favorite_tags "tag3"
    assert_equal ["tag1", "tag2", "tag3"].sort, @user.favorite_tags.sort

    @user.remove_favorite_tags "tag1"
    assert_equal ["tag2", "tag3"].sort, @user.favorite_tags.sort
    @user.remove_favorite_tags "tag0"
    assert_equal ["tag2", "tag3"].sort, @user.favorite_tags.sort
    @user.remove_favorite_tags "tag2 tag3"
    assert_equal nil, @user.favorite_tags
  end

  def test_tag_parser
    assert_nil @user.favorite_tags

    @user.add_favorite_tags "a" * 21
    assert_equal [].sort, @user.favorite_tags.sort

    @user.add_favorite_tags "."
    assert_equal [].sort, @user.favorite_tags.sort

    @user.add_favorite_tags "/ a/b"
    assert_equal ["ab"].sort, @user.favorite_tags.sort
  end

  def test_recover
    assert_no_difference "ActionMailer::Base.deliveries.size" do
      User.send_reset_password_instructions(:email => 'notexist@example.com')
    end

    assert_difference "ActionMailer::Base.deliveries.size" do
      User.send_reset_password_instructions(:email => @user.email)
    end
    assert_not_nil @user.reload.reset_password_token
    u = User.first :conditions => {:reset_password_token => @user.reset_password_token}
    assert_equal @user, u
    new_password = new_password_confirm = '87654321'
    assert u.reset_password(new_password, new_password_confirm), u.errors.to_s
    assert_nil u.reset_password_token
    assert_equal @user, User.authenticate(@user.username, '87654321')
  end

  def test_reset_password
    assert !@user.reset_password('12345678', '87654321')
    assert !@user.reset_password('', '')
  end
end
