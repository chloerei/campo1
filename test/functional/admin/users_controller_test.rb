require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  def setup
    @user = create_user
    @admin = create_admin
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
    get :show, :id => @user.id
    assert_redirected_to login_url

    login_as @user
    get :show, :id => @user.id
    assert_template 'errors/422'
    
    login_as @admin
    get :show, :id => @user.id
    assert_template 'show'
  end

  def test_destroy
    delete :destroy, :id => @user.id
    assert_redirected_to login_url

    login_as @user
    get :destroy, :id => @user.id
    assert_template 'errors/422'
    
    login_as @admin
    get :destroy, :id => @user.id
    assert_redirected_to :action => :index
  end

  def test_ban
    post :ban, :id => @user.id
    assert_redirected_to login_url

    login_as @user
    post :ban, :id => @user.id
    assert_template 'errors/422'
    
    login_as @admin
    post :ban, :id => @user.id
    assert_redirected_to :action => :show, :id => @user.id
    assert @user.banned?
  end

  def test_ban
    @user.ban!
    delete :unban, :id => @user.id
    assert_redirected_to login_url

    login_as @user
    delete :unban, :id => @user.id
    assert_template 'errors/422'
    
    login_as @admin
    delete :unban, :id => @user.id
    assert_redirected_to :action => :show, :id => @user.id
    assert !@user.reload.banned?
  end

  def test_ban_and_clean
    @user.topics.create :title => 'title', :content => 'content', :tags => 'tag1 tag2'
    post :ban_and_clean, :id => @user.id
    assert_redirected_to login_url

    login_as @user
    post :ban_and_clean, :id => @user.id
    assert_template 'errors/422'
    
    login_as @admin
    post :ban_and_clean, :id => @user.id
    assert_redirected_to :action => :show, :id => @user.id
    assert @user.reload.banned?
    assert @user.topics.empty?
  end
end
