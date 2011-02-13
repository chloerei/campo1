class RepliesController < ApplicationController
  before_filter :require_logined
  
  def new
    @topic = Topic.find params[:topic_id]
    @reply = @topic.replies.new
  end

  def create
    @topic = Topic.find params[:reply][:topic_id]
    @reply = @topic.replies.new params[:reply]
    @reply.user = current_user
    if @reply.save
      redirect_to topic_url(@topic, :skip => @topic.replies_count / 20 * 20)
    else
      render :new
    end
  end

  def edit
    @reply = current_user.replies.find params[:id]
  end

  def update
    @reply = current_user.replies.find params[:id]
    @topic = @reply.topic
    if @reply.update_attributes params[:reply]
      redirect_to @topic
    else
      render :edit
    end
  end
end
