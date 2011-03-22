class TopicsController < ApplicationController
  before_filter :login_by_token, :only => :interesting
  before_filter :require_logined, :require_user_not_banned, :except => [:index, :search, :show, :tagged, :newest]
  before_filter :layout_config, :only => [:index, :search, :show, :tagged, :interesting, :newest, :own, :collection]
  before_filter :set_cache_buster
  respond_to :rss, :only => [:newest, :tagged, :interesting]
  respond_to :js, :only => [:index, :newest, :interesting, :collection, :own, :replied, :show]

  def index
    @current = 'active'
    set_page_title I18n.t :_home
    @topics = Topic.desc(:actived_at).paginate :per_page => 20, :page => params[:page]
    prepare_for_index
    respond_with @topics do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def search
    @current = 'search'
  end

  def interesting
    set_page_title I18n.t :_interesting

    @current = 'interesting'
    if params[:format] == 'rss'
      @topics = Topic.where(:tags.in => current_user.favorite_tags.to_a).desc(:created_at).paginate :per_page => 20, :page => params[:page]
    else
      @topics = Topic.where(:tags.in => current_user.favorite_tags.to_a).desc(:actived_at).paginate :per_page => 20, :page => params[:page]
    end
    prepare_for_index

    respond_with @topics do |format|
      format.html { render :index }
      format.rss do
        @channel_link = interesting_topics_url
        render :topics, :layout => false
      end
      format.js { render :index, :layout => false }
    end
  end

  def own
    set_page_title I18n.t :_own
    @current = 'own'
    @topics = current_user.topics.desc(:actived_at).paginate :per_page => 20, :page => params[:page]
    prepare_for_index
    respond_with @topics do |format|
      format.html { render :index }
      format.js { render :index, :layout => false }
    end
  end

  def newest
    set_page_title I18n.t :_newest
    @current = 'newest'
    @topics = Topic.desc(:created_at).paginate :per_page => 20, :page => params[:page]
    prepare_for_index

    respond_with(@topics) do |format|
      format.html {render :index}
      format.rss  do
        @channel_link = newest_topics_url
        render :topics, :layout => false
      end
      format.js { render :index, :layout => false }
    end
  end

  def tagged
    @current = 'tagged'
    @tag = params[:tag]
    set_page_title @tag

    if params[:format] == 'rss'
        @topics = Topic.where(:tags => @tag).desc(:created_at).paginate :per_page => 20, :page => params[:page]
    else
        @topics = Topic.where(:tags => @tag).desc(:actived_at).paginate :per_page => 20, :page => params[:page]
    end
    prepare_for_index

    respond_with(@topics) do |format|
      format.html { render :index }
      format.rss  do
        @channel_link = tagged_topics_url(:tag => @tag)
        render :topics, :layout => false
      end
      format.js { render :index, :layout => false }
    end
  end

  def collection
    set_page_title I18n.t :_collection
    @current = 'collection'
    @topics = Topic.marked_by(current_user).desc(:actived_at).paginate :per_page => 20, :page => params[:page]
    prepare_for_index
    respond_with @topics do |format|
      format.html { render :index }
      format.js { render :index, :layout => false }
    end
  end

  def replied
    set_page_title I18n.t :_replied
    @current = 'replied'
    @topics = Topic.replied_by(current_user).desc(:actived_at).paginate :per_page => 20, :page => params[:page]
    prepare_for_index
    respond_with @topics do |format|
      format.html { render :index }
      format.js { render :index, :layout => false }
    end
  end

  def show
    @topic = Topic.find params[:id]
    set_page_title @topic.title
    last_page = @topic.replies_count == 0 ? nil : (@topic.replies_count / 20.to_f).ceil
    @replies = @topic.replies.asc(:created_at).paginate :per_page => 20, :page => (params[:page] || last_page )
    user_ids = @replies.map{|reply| reply.user_id}.push(@topic.user_id).flatten.compact.uniq
    @user_hash = User.create_user_hash(user_ids)

    if current_logined?
      current_user.read_topic @topic
      @reply = Reply.new
      @reply.topic_id = @topic.id
    end

    respond_with @topic do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def new
    set_page_title I18n.t 'topics.new.new_topic'
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
    set_page_title I18n.t 'topics.edit.edit_topic'
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

  def login_by_token
    if params[:token]
      @current_user = User.first :conditions => {:access_token => params[:token]}
    end
  end

  def layout_config
    self.show_head_html = true
    self.show_sidebar_bottom_html = true
  end

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
