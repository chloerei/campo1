class RepliesController < ApplicationController
  before_filter :require_logined
  
  def new
    @topic = Topic.find params[:topic_id]
    @reply = Reply.new
    @reply.topic_id = @topic.id
  end

  def create
    @topic = Topic.find params[:reply][:topic_id]
    @reply = @topic.replies.new params[:reply]
    @reply.user = current_user
    if @reply.save
      anchor = (@topic.replies_count == 0 ? nil : "replies-#{@topic.replies_count}")
      redirect_to topic_url(@topic, :anchor => anchor)
    else
      render :new, :topic_id => @topic.id
    end
  end

  def edit
    @reply = current_user.replies.find params[:id]
    @topic = @reply.topic
  end

  def update
    @reply = current_user.replies.find params[:id]
    @topic = @reply.topic
    if @reply.update_attributes params[:reply]
      redirect_to params[:return_to].blank? ? @topic : "#{params[:return_to]}##{@reply.id}"
    else
      render :edit
    end
  end
end
