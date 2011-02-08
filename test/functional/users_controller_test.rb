require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def test_new
    get :new
    assert_response :success, @response.body
  end
end
