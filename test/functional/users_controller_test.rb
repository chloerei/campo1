require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = Factory :user
    create_site_config
  end

  def test_new
    get :new
    assert_response :success, @response.body

    login_as @user
    get :new
    assert_redirected_to root_url
  end

  def test_create
    assert_difference "User.count" do
      post :create, :user => {:username => 'test2', :email => 'test2@test.com', :password => '12345678', :password_confirmation => '12345678'}
    end
    assert_redirected_to root_url
    assert current_user

    assert_no_difference "User.count" do
      post :create, :user => {:username => 'test3', :email => 'test3@test.com', :password => '12345678', :password_confirmation => '12345678'}
    end
    assert_redirected_to root_url
  end
end
