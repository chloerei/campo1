require 'test_helper'

class StatusesControllerTest < ActionController::TestCase
  def setup
    @user = Factory :user
    create_site_config
  end

  test "should get index" do
    get :index
    assert_response :success, @response.body
    assert_current_tab :all

    login_as @user
    get :index
    assert_response :success, @response.body
    assert_current_tab :feed

    session[:statuses_tab] = 'all'
    get :index
    assert_response :success, @response.body
    assert_current_tab :all

    session[:statuses_tab] = 'own'
    get :index
    assert_response :success, @response.body
    assert_current_tab :own
  end

  test "should get status" do
    get :show, :id => Factory(:status_base).id
    assert_response :success, @response.body
    
    get :show, :id => Factory(:status_reply).id
    assert_response :success, @response.body

    get :show, :id => Factory(:status_topic).id
    assert_response :success, @response.body
  end

  test "should get index, params is important than session" do
    login_as @user
    %w( feed own all ).each do |param_tab|
      get :index, :tab => param_tab
      assert_response :success, @response.body
      assert_current_tab param_tab

      %w( feed own all ).each do |tab|
        session[:statuses_tab] = tab
        get :index, :tab => param_tab
        assert_response :success, @response.body
        assert_current_tab param_tab
        assert_equal param_tab, session[:statuses_tab]
      end
    end
  end

  def assert_current_tab(name)
    assert_select '#tabs li.current a', I18n.t("statuses.subheader.#{name}")
  end
end
