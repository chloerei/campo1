require 'test_helper'

class Admin::DashboardControllerTest < ActionController::TestCase
  def setup
    @user  = Factory :user
    @admin = create_admin
    create_site_config
  end

  def test_show
    get :show
    assert_redirected_to login_url

    login_as @user
    get :show
    assert_template 'errors/422'

    login_as @admin
    get :show
    assert_template 'show'
  end
end
