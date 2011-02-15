require 'test_helper'

class Settings::FavoriteTagsControllerTest < ActionController::TestCase
  def setup
    @user = create_user
  end

  def test_show
    get :show
    assert_redirected_to login_url

    login_as @user
    get :show
    assert_response :success, @response.body
  end

  def test_create
    post :create, :tags => "tag1 tag2"
    assert_redirected_to login_url

    login_as @user
    post :create, :tags => "tag1 tag2"
    assert_equal 2, @user.favorite_tags.count
  end

  def test_destroy
    @user.add_favorite_tags "tag1 tag2 tag3"
    @user.save
    delete :destroy, :tags => "tag1 tag2"
    assert_redirected_to login_url

    login_as @user
    delete :destroy, :tags => "tag1 tag2"
    assert_equal ["tag3"], @user.favorite_tags
  end
end
