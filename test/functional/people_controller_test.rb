require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  def setup
    @user = create_user
  end

  def test_show
    get :show, :username => @user.username
    assert_response :success, @response.body
  end
end
