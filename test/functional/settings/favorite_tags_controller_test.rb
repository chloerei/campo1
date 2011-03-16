require 'test_helper'

class Settings::FavoriteTagsControllerTest < ActionController::TestCase
  def setup
    @user = create_user
    create_site_config
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
    assert_redirected_to :action => :show

    post :create, :tags => "tag1 tag2", :return_to => root_url
    assert_redirected_to root_url
  end

  def test_destroy
    @user.add_favorite_tags "tag1 tag2 tag3"
    @user.save
    delete :destroy, :tags => "tag1 tag2"
    assert_redirected_to login_url

    login_as @user
    delete :destroy, :tags => "tag1 tag2"
    assert_equal ["tag3"], @user.favorite_tags
    assert_redirected_to :action => :show

    delete :destroy, :tags => "tag1 tag2", :return_to => root_url
    assert_redirected_to root_url
  end
end
