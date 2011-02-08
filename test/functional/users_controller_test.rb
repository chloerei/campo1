require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = User.create :username => 'test', :email => 'test@test.com', :password => '12345678', :password_confirmation => '12345678'
  end

  def test_new
    get :new
    assert_response :success, @response.body
  end

  def test_create
    assert_difference "User.count" do
      post :create, :user => {:username => 'test2', :email => 'test2@test.com', :password => '12345678', :password_confirmation => '12345678'}
    end
    assert_redirected_to account_url
    assert current_user
  end
end
