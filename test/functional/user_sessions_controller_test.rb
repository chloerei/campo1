require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  def setup
    @user = create_user
    create_site_config
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

  def test_remember_me
    post :create, :user => {:login => 'test', :password => '12345678'}
    assert_equal @user, current_user
    assert_nil cookies['auth_token']

    login_as nil

    post :create, :user => {:login => 'test', :password => '12345678', :remember_me => "1"}
    assert_equal @user, current_user
    assert_not_nil cookies['auth_token']
  end

  def test_return_to
    post :create, :user => {:login => 'test', :password => '12345678'}, :return_to => topics_url
    assert_redirected_to topics_url
  end
end
