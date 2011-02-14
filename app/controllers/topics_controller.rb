class TopicsController < ApplicationController
  before_filter :require_logined, :except => [:index, :show]

  def index
    @topics = Topic.paginate :per_page => 20, :page => params[:page]
    user_ids = @topics.map{|topic| [topic.user_id, topic.last_replied_by_id]}.flatten.compact.uniq
    users = User.where(:_id.in => user_ids)
    @user_hash = {}
    users.each{|user| @user_hash[user.id] = user}
  end

  def show
    @topic = Topic.find params[:id]
    @replies = @topic.replies.paginate :per_page => 20, :page => params[:page]
    user_ids = @replies.map{|reply| reply.user_id}.push(@topic.user_id).flatten.compact.uniq
    users = User.where(:_id.in => user_ids)
    @user_hash = {}
    users.each{|user| @user_hash[user.id] = user}

    if current_logined?
      @reply = Reply.new
      @reply.topic_id = @topic.id
    end
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = current_user.topics.new params[:topic]
    if @topic.save
      redirect_to @topic
    else
      render :new
    end
  end

  def edit
    @topic = current_user.topics.find params[:id]
  end

  def update
    @topic = current_user.topics.find params[:id]
    if @topic.update_attributes params[:topic]
      redirect_to @topic
    else
      render :edit
    end
  end
end
