require 'test_helper'

class Admin::TopicsControllerTest < ActionController::TestCase
  def setup
    @user  = Factory :user
    @admin = create_admin
    @topic = Factory :topic
    create_site_config
  end

  def test_index
    get :index
    assert_redirected_to login_url

    login_as @user
    get :index
    assert_template 'errors/422'
    
    login_as @admin
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => @topic.id
    assert_redirected_to login_url

    login_as @user
    get :show, :id => @topic.id
    assert_template 'errors/422'
    
    login_as @admin
    get :show, :id => @topic.id
    assert_template 'show'
  end

  def test_destroy
    delete :destroy, :id => @topic.id
    assert_redirected_to login_url

    login_as @user
    get :destroy, :id => @topic.id
    assert_template 'errors/422'
    
    login_as @admin
    get :destroy, :id => @topic.id
    assert_redirected_to :action => :index
  end

  def test_close
    post :close, :id => @topic.id
    assert_redirected_to login_url

    login_as @user
    post :close, :id => @topic.id
    assert_template 'errors/422'
    
    login_as @admin
    post :close, :id => @topic.id
    assert_redirected_to :action => :show, :id => @topic.id
    assert @topic.reload.closed?
  end

  def test_open
    @topic.close!
    post :open, :id => @topic.id
    assert_redirected_to login_url

    login_as @user
    post :open, :id => @topic.id
    assert_template 'errors/422'
    
    login_as @admin
    post :open, :id => @topic.id
    assert_redirected_to :action => :show, :id => @topic.id
    assert !@topic.reload.closed?
  end
end
