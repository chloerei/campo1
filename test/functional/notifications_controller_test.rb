require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  def setup
    @user = create_user
    @user.send_notification
  end

  def test_index
    get :index
    assert_redirected_to login_url

    login_as @user
    get :index
    assert_response :success, @response.body
  end

  def test_destroy
    delete :destroy, :id => @user.notifications.first.id
    assert_redirected_to login_url

    login_as @user
    assert_difference "@user.notifications.count", -1 do
      delete :destroy, :id => @user.notifications.first.id
    end
    assert_redirected_to :action => :index
  end
end
