class TopicsController < ApplicationController
  before_filter :require_logined, :except => [:index, :show, :tagged, :interesting, :newest]

  def index
    @current = :active
    @topics = Topic.desc(:actived_at).paginate :per_page => 20, :page => params[:page]
    user_ids = @topics.map{|topic| [topic.user_id, topic.last_replied_by_id]}.flatten.compact.uniq
    @user_hash = User.create_user_hash(user_ids)
    @recent_tags = get_recent_tags @topics
  end

  def interesting
    if current_logined?
      @topics = Topic.where(:tags.in => current_user.favorite_tags.to_a).desc(:actived_at).paginate :per_page => 20, :page => params[:page]
      user_ids = @topics.map{|topic| [topic.user_id, topic.last_replied_by_id]}.flatten.compact.uniq
      @user_hash = User.create_user_hash(user_ids)
      @recent_tags = get_recent_tags @topics
      @current = :interesting
      render :index
    else
      render :interesting_help
    end
  end

  def own
    @topics = current_user.topics.desc(:actived_at).paginate :per_page => 20, :page => params[:page]
    user_ids = @topics.map{|topic| [topic.user_id, topic.last_replied_by_id]}.flatten.compact.uniq
    @user_hash = User.create_user_hash(user_ids)
    @recent_tags = get_recent_tags @topics
    @current = :own
    render :index
  end

  def newest
    @current = :newest
    @topics = Topic.desc(:created_at).paginate :per_page => 20, :page => params[:page]
    user_ids = @topics.map{|topic| [topic.user_id, topic.last_replied_by_id]}.flatten.compact.uniq
    @user_hash = User.create_user_hash(user_ids)
    @recent_tags = get_recent_tags @topics
    render :index
  end

  def tagged
    @tag = params[:tag]
    @topics = Topic.where(:tags => @tag).desc(:actived_at).paginate :per_page => 20, :page => params[:page]
    user_ids = @topics.map{|topic| [topic.user_id, topic.last_replied_by_id]}.flatten.compact.uniq
    @user_hash = User.create_user_hash(user_ids)
  end

  def collection
    @current = :collection
    @topics = Topic.marked_by(current_user).desc(:actived_at).paginate :per_page => 20, :page => params[:page]
    user_ids = @topics.map{|topic| [topic.user_id, topic.last_replied_by_id]}.flatten.compact.uniq
    @user_hash = User.create_user_hash(user_ids)
    render :index
  end

  def show
    @topic = Topic.find params[:id]
    @replies = @topic.replies.asc(:created_at).paginate :per_page => 20, :page => params[:page]
    user_ids = @replies.map{|reply| reply.user_id}.push(@topic.user_id).flatten.compact.uniq
    @user_hash = User.create_user_hash(user_ids)

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

  def mark
    @topic = Topic.find params[:id]
    @topic.mark_by current_user
    redirect_to @topic
  end

  def unmark
    @topic = Topic.find params[:id]
    @topic.unmark_by current_user
    redirect_to @topic
  end

  private

  def get_recent_tags(topics)
    recent_tags = {}
    topics.each do |topic|
      if !topic.tags.blank?
        topic.tags.each do |tag|
          recent_tags[tag] = recent_tags[tag].to_i + 1
        end
      end
    end
    recent_tags
  end
end
