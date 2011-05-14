require 'test_helper'

class Admin::RepliesControllerTest < ActionController::TestCase
  def setup
    @user  = Factory :user
    @admin = create_admin
    @topic = Factory :topic
    @reply = Factory :reply
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
    get :show, :id => @reply.id
    assert_redirected_to login_url

    login_as @user
    get :show, :id => @reply.id
    assert_template 'errors/422'
    
    login_as @admin
    get :show, :id => @reply.id
    assert_template 'show'
  end

  def test_destroy
    delete :destroy, :id => @reply.id
    assert_redirected_to login_url

    login_as @user
    get :destroy, :id => @reply.id
    assert_template 'errors/422'
    
    login_as @admin
    get :destroy, :id => @reply.id
    assert_redirected_to :action => :index
  end
end
