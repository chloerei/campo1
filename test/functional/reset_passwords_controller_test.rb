require 'test_helper'

class ResetPasswordsControllerTest < ActionController::TestCase
  def setup
    @user = create_user
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
end
