class NotificationsController < ApplicationController
  before_filter :require_logined

  def index
    @notifications = current_user.notifications.desc(:created_at)
  end

  def destroy
    @notification = current_user.notifications.find params[:id]
    @notification.destroy
    redirect_to :action => :index
  end
end
