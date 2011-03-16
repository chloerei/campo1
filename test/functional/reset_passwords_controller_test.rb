require 'test_helper'

class ResetPasswordsControllerTest < ActionController::TestCase
  def setup
    @user = create_user
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
    assert_nil @user.reset_password_token
    assert_difference "ActionMailer::Base.deliveries.size" do
      post :create, :email => @user.email
    end
    assert_not_nil @user.reload.reset_password_token
    assert_response :success, @response.body

    assert_no_difference "ActionMailer::Base.deliveries.size" do
      post :create, :email => ''
    end
    assert_template 'new'
  end

  def test_show
    @user.make_reset_password_token
    get :show, :token => @user.reset_password_token
    assert_response :success, @response.body

    get :show
    assert_template 'errors/422'
    get :show, :token => 'no exist'
    assert_template 'errors/422'

    login_as @user
    get :show, :token => @user.reset_password_token
    assert_redirected_to root_url
  end

  def test_update
    @user.make_reset_password_token

    put :update, :new_password => '87654321', :new_password_confirmation => '87654321'
    assert_template 'errors/422'

    login_as @user
    put :update, :new_password => '87654321', :new_password_confirmation => '87654321'
    assert_redirected_to root_url

    login_as nil
    put :update, :new_password => '87654321', :new_password_confirmation => '12345678', :token => @user.reset_password_token
    assert_template :show

    put :update, :new_password => '87654321', :new_password_confirmation => '87654321', :token => @user.reset_password_token
    assert_redirected_to root_url
    assert_not_nil current_user
  end
end
