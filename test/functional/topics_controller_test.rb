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

  def test_create
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
end
