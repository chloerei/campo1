class TopicsController < ApplicationController
  def index
    @topics = Topic.skip(params[:skip].to_i).limit(20).cache
    user_ids = @topics.map{|topic| [topic.user_id, topic.last_replied_by_id]}.flatten.compact.uniq
    users = User.where(:_id.in => user_ids)
    @user_hash = {}
    users.each{|user| @user_hash[user.id] = user}
  end

  def show
    @topic = Topic.find params[:id]
    @replies = @topic.replies.skip(params[:skip].to_i).limit(20).cache
    user_ids = @replies.map{|reply| reply.user_id}.push(@topic.user_id).flatten.compact.uniq
    users = User.where(:_id.in => user_ids)
    @user_hash = {}
    users.each{|user| @user_hash[user.id] = user}
  end
end
