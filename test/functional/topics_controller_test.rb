require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_response :success, @response.body
  end
end
