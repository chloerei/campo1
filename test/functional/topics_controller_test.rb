require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  def setup
    @user = create_user
    @topic = @user.topics.create :title => 'title', :content => 'content'
    
  end

  def test_index
    get :index
    assert_response :success, @response.body
  end

  def test_show
    get :show, :id => @topic.to_param
    assert_response :success, @response.body
  end
end
