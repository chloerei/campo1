require 'test_helper'

class Admin::TopicsControllerTest < ActionController::TestCase
  def setup
    @user = create_user
    @admin = create_admin
    @topic = @user.topics.create :title => 'title', :content => 'content', :tags => 'tag1 tag2'
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
end
