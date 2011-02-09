require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = User.create :username => 'test', :email => 'test@test.com', :password => '12345678', :password_confirmation => '12345678'
  end

  def test_new
    get :new
    assert_response :success, @response.body

    login_as @user
    get :new
    assert_redirected_to account_url
  end

  def test_create
    assert_difference "User.count" do
      post :create, :user => {:username => 'test2', :email => 'test2@test.com', :password => '12345678', :password_confirmation => '12345678'}
    end
    assert_redirected_to account_url
    assert current_user

    assert_no_difference "User.count" do
      post :create, :user => {:username => 'test3', :email => 'test3@test.com', :password => '12345678', :password_confirmation => '12345678'}
    end
    assert_redirected_to account_url
  end

  def test_show
    get :show
    assert_redirected_to login_url

    login_as @user
    get :show
    assert_response :success, @response.body
  end

  def test_update
    post :update, :user => {:username => 'Rei'}
    assert_redirected_to login_url
    
    login_as @user

    post :update, :user => {:username => 'Rei'}
    assert_equal 'Rei', current_user.username

    # ignore password relate
    post :update, :user => {:password => '87654321', :password_confirmation => '87654321', :current_password => '12345678'}
    assert_equal @user, User.authenticate(@user.email, '12345678')
  end
end
