require 'test_helper'

class Admin::TopicsControllerTest < ActionController::TestCase
  def setup
    @user = create_user
    @admin = create_admin
  end

  def test_index
    get :index
    assert_redirected_to login_url

    login_as @user
    get :index
    assert_template 'errors/422'
    
    login_as @admin
    get :index
    assert_template 'index'
  end
end
