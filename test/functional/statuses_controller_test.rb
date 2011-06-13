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
    get :show, :id => Factory(:status_base).id
    assert_response :success, @response.body
    
    get :show, :id => Factory(:status_reply).id
    assert_response :success, @response.body

    get :show, :id => Factory(:status_topic).id
    assert_response :success, @response.body
  end

  test "should get own if logined" do
    get :own
    assert_redirected_to login_url 

    login_as @user
    get :own
    assert_response :success, @response.body
  end

  test "should get all" do
    get :all
    assert_response :success, @response.body
  end
end
