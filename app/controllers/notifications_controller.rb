class NotificationsController < ApplicationController
  before_filter :require_logined
  respond_to :html, :js, :only => :destroy

  def index
    @notifications = current_user.notifications.desc(:created_at)
  end

  def destroy
    @notification = current_user.notifications.find params[:id]
    @notification.destroy
    respond_with @notification, :location => url_for(:action => :index) do |format|
      format.js {render :layout => false}
    end
  end
end
