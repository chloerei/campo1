require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  def setup
    @user  = Factory :user
    @topic = Factory(:topic, :user => @user)
    create_site_config
  end

  def test_index
    get :index
    assert_response :success, @response.body
    assert_current_tab :active

    login_as @user
    get :index
    assert_response :success, @response.body
    assert_current_tab :active

    %w( newest interesting own replied collection ).each do |tab|
      get :index, :tab => tab
      assert_response :success, @response.body
      assert_current_tab tab
    end
  end

  test "should get index, params is important than session" do
    login_as @user
    %w( active newest interesting own collection replied ).each do |param_tab|
      get :index, :tab => param_tab
      assert_response :success, @response.body
      assert_current_tab param_tab

      %w( active newest interesting own collection replied ).each do |tab|
        session[:topics_tab] = tab
        get :index, :tab => param_tab
        assert_response :success, @response.body
        assert_current_tab param_tab
        assert_equal param_tab, session[:topics_tab]
      end
    end
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
    get :tagged, :tag => 'test', :foramt => :rss
    assert_response :success, @response.body

    assert_routing '/topics/tagged/min.us', { :controller => "topics", :action => "tagged", :tag => "min.us" }
  end
  
  def test_newest
    get :newest, :format => :rss
    assert_template :topics
  end

  def test_interesting
    login_as @user
    get :interesting, :format => :rss
    assert_template :topics

    login_as nil
    get :interesting, :format => :rss, :token => @user.access_token
    assert_template :topics
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

  test "should mute topic" do
    post :mute, :id => @topic.id
    assert_redirected_to login_url

    login_as @user
    post :mute, :id => @topic.id
    assert @topic.reload.muter_ids.include?(@user.id)
  end

  test "should unmute topic" do
    @topic.mute_by @user
    assert @topic.reload.muter_ids.include?(@user.id)
    delete :unmute, :id => @topic.id
    assert_redirected_to login_url
    
    login_as @user
    delete :unmute, :id => @topic.id
    assert !@topic.reload.muter_ids.include?(@user.id)
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

  def assert_current_tab(name)
    assert_select '#tabs li.current a', I18n.t("topics.subheader.#{name}")
  end
end
