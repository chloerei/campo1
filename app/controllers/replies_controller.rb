class RepliesController < ApplicationController
  before_filter :require_logined, :require_user_not_banned
  respond_to :js, :only => [:create]
  
  def new
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
      @reply.save
      respond_with @reply do |format|
        format.html do
          if @reply.valid?
            redirect_to topic_url_with_last_anchor(@topic)
          else
            render :new, :topic_id => @topic.id
          end
        end
        format.js { render :layout => false }
      end
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
      redirect_to params[:return_to].blank? ? @topic : "#{params[:return_to]}#reply-#{@reply.id}"
    else
      render :edit
    end
  end
end
