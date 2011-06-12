require 'test_helper'

class StatusesControllerTest < ActionController::TestCase
  def setup
    @user = Factory :user
  end
  test "should get index" do
    get :index
    assert_response :success, @response.body

    login_as @user
    get :index
    assert_response :success, @response.body
  end
end
