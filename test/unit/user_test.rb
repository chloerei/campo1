require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user  = Factory(:user, :username => 'test', :email => 'test@test.com', :password => '12345678',
                     :password_confirmation => '12345678')
    @admin = create_admin
  end

  test "should block user" do
    user_two = Factory :user
    assert_difference "@user.blockings.count" do
      assert_difference "user_two.blockers.count" do
        @user.block user_two
      end
    end
    assert_difference "@user.blockings.count", -1 do
      assert_difference "user_two.blockers.count", -1 do
        @user.unblock user_two
      end
    end
  end

  test "should not block self" do
    assert_no_difference "@user.blockings.count" do
      assert_no_difference "@user.blockers.count" do
        @user.block @user
      end
    end
  end

  test "block shoud take unfollow" do
    user_two = Factory :user
    @user.follow user_two
    assert @user.followings.include?(user_two)
    @user.reload
    @user.block user_two
    assert !@user.followings.include?(user_two)
  end

  test "if blocked, ignore follow request" do
    user_two = Factory :user
    @user.block user_two
    @user.reload
    assert_no_difference "@user.followings.count" do
      assert_no_difference "user_two.followers.count" do
        @user.follow user_two
      end
    end
  end

  test "should follow user" do
    user_two = Factory :user
    assert_difference "@user.followings.count" do
      assert_difference "user_two.followers.count" do
        @user.follow user_two
      end
    end
    assert_difference "@user.followings.count", -1 do
      assert_difference "user_two.followers.count", -1 do
        @user.unfollow user_two
      end
    end
  end

  test "should not follow self" do
    assert_no_difference "@user.followings.count" do
      assert_no_difference "@user.followers.count" do
        @user.follow @user
      end
    end
  end

  test "should have many status" do
    assert_difference "@user.statuses.count" do
      @user.statuses.create({}, Status::Base)
    end
  end

  def test_access_token
    assert_not_nil @user.access_token
    old_token = @user.access_token
    @user.reset_access_token
    assert_not_equal old_token, @user.access_token
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
    50.times { @user.send_notification({:created_at => Time.now + 1}) }
    assert_equal 50, @user.reload.notifications.size
    assert !@user.notifications.include?(n1)
    assert !@user.notifications.include?(n2)
  end

  def test_read_topic
    topic = @user.topics.create :title => 'title', :content => 'content'
    reply = topic.replies.new :content => 'conten'
    reply.user = @admin
    reply.save

    assert_difference "@user.reload.notifications.count" do
      @user.send_notification({:user_id => @admin.id,
                               :topic_id => topic.id,
                               :reply_id => reply.id,
                               :text     => reply.content}, Notification::Mention)
    end

    assert_difference "@user.notifications.count", -1 do
      @user.read_topic topic
    end
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
    topic = Factory :topic, :user => @user
    Factory :reply, :topic => topic
    Factory :reply, :topic => topic, :user => @user
    topic2 = Factory :topic
    Factory :reply, :topic => topic2
    Factory :reply, :topic => topic2, :user => @user
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

  def test_tag_parser
    assert_nil @user.favorite_tags
    
    assert_equal [], @user.parse_tags_from_string("a" * 21)
    assert_equal [], @user.parse_tags_from_string(".")
    assert_equal ["ab"], @user.parse_tags_from_string("/ a/b")
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
