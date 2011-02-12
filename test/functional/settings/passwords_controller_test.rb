require 'test_helper'

class Settings::PasswordsControllerTest < ActionController::TestCase
  def setup
    @user = create_user
  end

  def test_show
    get :show
    assert_redirected_to login_url

    login_as @user
    get :show
    assert_response :success, @response.body
  end

  def test_update
    post :update, :user => {:password => '87654321', :password_confirmation => '87654321', :current_password => '12345678'}
    assert_redirected_to login_url
    
    login_as @user

    # ignore params no password relate
    post :update, :user => {:username => 'Rei'}
    assert_redirected_to :action => :show
    assert_nil User.authenticate('Rei', 12345678)

    post :update, :user => {:password => '87654321', :password_confirmation => '87654321'}
    assert_template :show
    assert_equal @user, User.authenticate(@user.username, '12345678')

    post :update, :user => {:password => '87654321', :password_confirmation => '87654321', :current_password => '12345678'}
    assert_equal @user, User.authenticate(@user.username, '87654321')
    assert_redirected_to :action => :show
  end
end
