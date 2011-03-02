class TopicsController < ApplicationController
  before_filter :require_logined, :require_user_not_banned, :except => [:index, :show, :tagged, :interesting, :newest]
  respond_to :html, :rss, :only => [:newest, :tagged]

  def index
    @current = :active
    set_page_title I18n.t :home
    @topics = Topic.desc(:actived_at).paginate :per_page => 20, :page => params[:page]
    prepare_for_index
  end

  def interesting
    set_page_title I18n.t :interesting
    if current_logined?
      @current = :interesting
      @topics = Topic.where(:tags.in => current_user.favorite_tags.to_a).desc(:actived_at).paginate :per_page => 20, :page => params[:page]
      prepare_for_index
      render :index
    else
      render :interesting_help
    end
  end

  def own
    set_page_title I18n.t :own
    @current = :own
    @topics = current_user.topics.desc(:actived_at).paginate :per_page => 20, :page => params[:page]
    prepare_for_index
    render :index
  end

  def newest
    set_page_title I18n.t :newest
    @current = :newest
    @topics = Topic.desc(:created_at).paginate :per_page => 20, :page => params[:page]
    prepare_for_index

    respond_with(@topics) do |format|
      format.html {render :index}
      format.rss  do
        @channel_link = newest_topics_url
        render :topics, :layout => false
      end
    end
  end

  def tagged
    @current = :tagged
    @tag = params[:tag]
    set_page_title @tag
    respond_with(@topics) do |format|
      format.html do
        @topics = Topic.where(:tags => @tag).desc(:actived_at).paginate :per_page => 20, :page => params[:page]
        prepare_for_index
      end
      format.rss  do
        @topics = Topic.where(:tags => @tag).desc(:created_at).paginate :per_page => 20, :page => params[:page]
        prepare_for_index
        @channel_link = tagged_topics_url(:tag => @tag)
        render :topics, :layout => false
      end
    end
  end

  def collection
    set_page_title I18n.t :collection
    @current = :collection
    @topics = Topic.marked_by(current_user).desc(:actived_at).paginate :per_page => 20, :page => params[:page]
    prepare_for_index
    render :index
  end

  def show
    @topic = Topic.find params[:id]
    set_page_title @topic.title
    @replies = @topic.replies.asc(:created_at).paginate :per_page => 20, :page => params[:page]
    user_ids = @replies.map{|reply| reply.user_id}.push(@topic.user_id).flatten.compact.uniq
    @user_hash = User.create_user_hash(user_ids)

    if current_logined?
      @reply = Reply.new
      @reply.topic_id = @topic.id
    end
  end

  def new
    set_page_title I18n.t :new_topic
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
    set_page_title I18n.t :edit_topic
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

  def prepare_for_index
    user_ids = @topics.map{|topic| [topic.user_id, topic.last_replied_by_id]}.flatten.compact.uniq
    @user_hash = User.create_user_hash(user_ids)
    @recent_tags = get_recent_tags @topics
  end

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
