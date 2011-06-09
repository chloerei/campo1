require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  def setup
    @user = Factory :user
    @topic = Factory(:topic , :user => @user)
    create_site_config
  end

  test "should follow user" do
    post :follow, :username => @user.username
    assert_redirected_to login_url

    user_two = Factory :user
    login_as user_two
    assert_difference "@user.followers.count" do
      assert_difference "user_two.followings.count" do
        post :follow, :username => @user.username
        assert_redirected_to person_url(:username => @user.username)
      end
    end
  end

  test "should unfollow user" do
    delete :unfollow, :username => @user.username
    assert_redirected_to login_url

    user_two = Factory :user
    @user.add_follower user_two
    login_as user_two
    assert_difference "@user.followers.count", -1 do
      assert_difference "user_two.followings.count", -1 do
        delete :unfollow, :username => @user.username
        assert_redirected_to person_url(:username => @user.username)
      end
    end
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
