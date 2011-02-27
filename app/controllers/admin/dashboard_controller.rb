class Admin::DashboardController < Admin::BaseController
  def show
    @today_topics_count = Topic.count :conditions => {:created_at.gt => Date.today.to_time}
    @today_replies_count = Reply.count :conditions => {:created_at.gt => Date.today.to_time}
    @today_users_count = User.count :conditions => {:created_at.gt => Date.today.to_time}
  end
end
