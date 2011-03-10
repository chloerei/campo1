class NotificationsController < ApplicationController
  before_filter :require_logined
  respond_to :html, :js, :only => :destroy

  def index
    @notifications = current_user.notifications.desc(:created_at)
    if @notifications.any?
      user_ids = []
      topic_ids = []
      @notifications.each do |notification|
        case notification
        when Notification::Mention
          user_ids << notification.reply_user_id
          topic_ids << notification.topic_id
        end
      end
      @user_hash = User.create_user_hash(user_ids)
      @topic_hash = Topic.create_topic_hash(topic_ids)
    end
  end

  def destroy
    @notification = current_user.notifications.find params[:id]
    @notification.destroy
    respond_with @notification, :location => url_for(:action => :index) do |format|
      format.js {render :layout => false}
    end
  end
end
