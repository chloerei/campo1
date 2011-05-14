require 'test_helper'

class Settings::AccountsControllerTest < ActionController::TestCase
  def setup
    @user = Factory(:user, :password => '12345678', :password_confirmation => '12345678')
    create_site_config
  end

  def test_show
    get :show
    assert_redirected_to login_url

    login_as @user
    get :show
    assert_response :success, @response.body
  end

  def test_update
    post :update, :user => {:username => 'Rei', :current_password => '12345678'}
    assert_redirected_to login_url
    
    login_as @user

    post :update, :user => {:username => 'Rei'}
    assert_template :show

    post :update, :user => {:username => 'Rei', :current_password => '12345678'}
    assert_redirected_to :action => :show
    assert_not_nil User.authenticate('Rei', '12345678')

    # ignore password relate
    post :update, :user => {:password => '87654321', :password_confirmation => '87654321', :current_password => '12345678'}
    assert_equal @user, User.authenticate(@user.email, '12345678')
  end
end
