require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = create_user
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
    assert @user.update_attributes(:password => '', :password_confirmation => '11111111', :current_password => '12345678')
    assert_equal @user, User.authenticate('test', '12345678')

    assert @user.update_attributes(:password => '11111111', :password_confirmation => '11111111', :current_password => '12345678')
    assert_equal @user, User.authenticate('test', '11111111')
  end

end
