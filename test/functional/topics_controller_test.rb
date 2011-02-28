require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  def setup
    @user = create_user
    @topic = @user.topics.create :title => 'title', :content => 'content', :tags => 'tag1 tag2'
  end

  def test_index
    get :index
    assert_response :success, @response.body
  end

  def test_show
    get :show, :id => @topic.to_param
    assert_response :success, @response.body
  end

  def test_new
    get :new
    assert_redirected_to login_url

    login_as @user
    get :new
    assert_response :success, @response.body
  end

  def test_create
    post :create, :topic => {:title => 'title', :content => 'content', :tags => 'tag1, tag2'}
    assert_redirected_to login_url

    login_as @user
    assert_difference "Topic.count" do
      post :create, :topic => {:title => 'title', :content => 'content', :tags => 'tag1, tag2'}
    end
    assert_response :redirect, @response.body
  end
  
  def test_edit
    get :edit, :id => @topic.id
    assert_redirected_to login_url

    login_as @user
    get :edit, :id => @topic.id
    assert_response :success, @response.body
  end

  def test_update
    put :update, :id => @topic.id, :topic => {:title => 'title', :content => 'content', :tags => 'tag1, tag2'}
    assert_redirected_to login_url

    login_as @user
    put :update, :id => @topic.id, :topic => {:title => 'title', :content => 'content', :tags => 'tag1, tag2'}
    assert_response :redirect, @response.body
  end

  def test_tagged
    get :tagged, :tag => 'test'
    assert_response :success, @response.body
  end
  
  def test_interesting
    get :interesting
    assert_template :interesting_help

    login_as @user
    get :interesting
    assert_template :index
  end

  def test_own
    get :own
    assert_redirected_to login_url

    login_as @user
    get :own
    assert_template :index
  end

  def test_newest
    get :newest
    assert_template :index
  end

  def test_collection
    get :collection
    assert_redirected_to login_url

    login_as @user
    get :collection
    assert_response :success, @response.body
  end

  def test_mark
    post :mark, :id => @topic.id
    assert_redirected_to login_url

    login_as @user
    post :mark, :id => @topic.id
    assert_redirected_to @topic
    assert_equal [@user.id], @topic.reload.marker_ids
  end

  def test_unmark
    @topic.mark_by @user
    assert_equal [@user.id], @topic.reload.marker_ids
    delete :unmark, :id => @topic.id
    assert_redirected_to login_url

    login_as @user
    delete :unmark, :id => @topic.id
    assert_redirected_to @topic
    assert_equal [], @topic.reload.marker_ids
  end

  def test_require_user_not_banned?
    @user.ban!
    login_as @user

    get :new
    assert_template 'errors/422'

    post :create, :topic => {:title => 'title', :content => 'content', :tags => 'tag1, tag2'}
    assert_template 'errors/422'

    get :edit, :id => @topic.id
    assert_template 'errors/422'

    put :update, :id => @topic.id, :topic => {:title => 'title', :content => 'content', :tags => 'tag1, tag2'}
    assert_template 'errors/422'

    post :mark, :id => @topic.id
    assert_template 'errors/422'

    delete :unmark, :id => @topic.id
    assert_template 'errors/422'
  end
end
