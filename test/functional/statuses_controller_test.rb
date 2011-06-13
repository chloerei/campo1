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

  test "should get status" do
    get :show, :id => Factory(:status_base)
    assert_response :success, @response.body
    
    get :show, :id => Factory(:status_reply)
    assert_response :success, @response.body

    get :show, :id => Factory(:status_topic)
    assert_response :success, @response.body
  end
end
