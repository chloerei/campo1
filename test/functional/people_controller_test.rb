require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  def setup
    @user = create_user
    create_site_config
  end

  def test_show
    get :show, :username => @user.username
    assert_response :success, @response.body
  end

  def test_topics
    get :topics, :username => @user.username
    assert_response :success, @response.body

    get :topics, :username => @user.username, :format => :rss
    assert_response :success, @response.body
  end
end
