class RepliesController < ApplicationController
  before_filter :require_logined, :require_user_not_banned
  
  def new
    set_page_title I18n.t :new_reply
    @topic = Topic.find params[:topic_id]
    if @topic.closed?
      render_422
    else
      @reply = Reply.new
      @reply.topic_id = @topic.id
    end
  end

  def create
    @topic = Topic.find params[:reply][:topic_id]
    if @topic.closed?
      render_422
    else
      @reply = @topic.replies.new params[:reply]
      @reply.user = current_user
      if @reply.save
        anchor = (@topic.replies_count == 0 ? nil : "replies-#{@topic.replies_count}")
        redirect_to topic_url(@topic, :anchor => anchor)
      else
        set_page_title I18n.t :new_reply
        render :new, :topic_id => @topic.id
      end
    end
  end

  def edit
    set_page_title I18n.t :edit_reply
    @reply = current_user.replies.find params[:id]
    @topic = @reply.topic
  end

  def update
    @reply = current_user.replies.find params[:id]
    @topic = @reply.topic
    if @reply.update_attributes params[:reply]
      redirect_to params[:return_to].blank? ? @topic : "#{params[:return_to]}##{@reply.id}"
    else
      set_page_title I18n.t :edit_reply
      render :edit
    end
  end
end
