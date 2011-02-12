require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  def setup
    @user = create_user
    
  end

  def test_index
    get :index
    assert_response :success, @response.body
  end

  def test_show
  end
end
