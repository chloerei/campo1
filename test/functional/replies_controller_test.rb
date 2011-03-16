require 'test_helper'

class RepliesControllerTest < ActionController::TestCase
  def setup
    @user = create_user
    @topic = @user.topics.create :title => 'title', :content => 'content', :tags => 'tag1 tag2'
    @reply = @topic.replies.new :content => 'hi'
    @reply.user = @user
    @reply.save
    create_site_config
  end

  def test_new
    get :new, :topic_id => @topic.id
    assert_redirected_to login_url
    
    login_as @user
    get :new, :topic_id => @topic.id
    assert_response :success, @response.body
  end

  def test_create
    post :create, :reply => {:topic_id => @topic.id, :content => 'hi'}
    assert_redirected_to login_url

    login_as @user
    assert_difference "@topic.replies.count" do
      post :create, :reply => {:topic_id => @topic.id, :content => 'hi'}
    end
  end
  
  def test_edit
    get :edit, :id => @reply.id
    assert_redirected_to login_url

    login_as @user
    get :edit, :id => @reply.id
    assert_response :success, @response.body
  end

  def test_update
    put :update, :id => @reply.id, :reply => {:content => 'hi'}
    assert_redirected_to login_url

    login_as @user
    put :update, :id => @reply.id, :reply => {:content => 'hi'}
    assert_response :redirect, @response.body
  end

  def test_require_user_not_banned
    @user.ban!
    login_as @user
    
    get :new, :topic_id => @topic.id
    assert_template 'errors/422'

    post :create, :reply => {:topic_id => @topic.id, :content => 'hi'}
    assert_template 'errors/422'

    get :edit, :id => @reply.id
    assert_template 'errors/422'

    put :update, :id => @reply.id, :reply => {:content => 'hi'}
    assert_template 'errors/422'
  end

  def test_require_topic_not_close
    @topic.close!
    login_as @user
    
    get :new, :topic_id => @topic.id
    assert_template 'errors/422'

    post :create, :reply => {:topic_id => @topic.id, :content => 'hi'}
    assert_template 'errors/422'
  end
end
