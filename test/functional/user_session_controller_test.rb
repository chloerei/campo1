require 'test_helper'

class UserSessionControllerTest < ActionController::TestCase
  def setup
    @user = User.create :username => 'test', :email => 'test@test.com', :password => '12345678', :password_confirmation => '12345678'
  end

  def test_login
    get :new
    assert_response :success, @response.body

    post :create, :user => {:login => 'test', :password => '12345678'}
    assert_redirected_to root_url
    assert_equal @user, current_user

    delete :destroy
    assert_redirected_to root_url
    assert_equal false, current_user
  end
end
