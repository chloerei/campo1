class TopicsController < ApplicationController
  before_filter :login_by_token, :only => :interesting
  before_filter :require_logined, :require_user_not_banned, :except => [:index, :search, :show, :tagged, :newest]
  before_filter :layout_config, :only => [:index, :search, :show, :tagged]
  respond_to :html, :rss, :only => [:tagged]
  respond_to :rss, :only => [:newest, :interesting]

  def index
    @tab = filter_tab(params[:tab]) || filter_tab(session[:topics_tab])
    session[:topics_tab] = @tab

    @topics = case @tab
              when 'newest'
                @rss_path = newest_topics_url(:format => :rss)
                Topic.desc(:created_at).paginate :per_page => 20, :page => params[:page]
              when 'interesting'
                @rss_path = interesting_topics_url(:format => :rss, :token => current_user.access_token)
                if params[:format] == 'rss'
                  Topic.where(:tags.in => current_user.favorite_tags.to_a).desc(:created_at).paginate :per_page => 20, :page => params[:page]
                else
                  Topic.where(:tags.in => current_user.favorite_tags.to_a).desc(:actived_at).paginate :per_page => 20, :page => params[:page]
                end
              when 'own'
                current_user.topics.desc(:actived_at).paginate :per_page => 20, :page => params[:page]
              when 'replied'
                Topic.replied_by(current_user).desc(:actived_at).paginate :per_page => 20, :page => params[:page]
              when 'collection'
                Topic.marked_by(current_user).desc(:actived_at).paginate :per_page => 20, :page => params[:page]
              else
                Topic.desc(:actived_at).paginate :per_page => 20, :page => params[:page]
              end
    prepare_for_index
  end

  def search
  end

  # rss
  def interesting
    @topics = Topic.where(:tags.in => current_user.favorite_tags.to_a).desc(:created_at).paginate :per_page => 20, :page => params[:page]
    prepare_for_index

    respond_with @topics do |format|
      format.rss do
        @channel_link = interesting_topics_url
        render :topics, :layout => false
      end
    end
  end

  # rss
  def newest
    @topics = Topic.desc(:created_at).paginate :per_page => 20, :page => params[:page]
    prepare_for_index

    respond_with(@topics) do |format|
      format.rss  do
        @channel_link = newest_topics_url
        render :topics, :layout => false
      end
    end
  end

  def tagged
    @rss_path = tagged_topics_url(:format => :rss)
    @current = 'tagged'
    @tag = params[:tag]

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
    end
  end

  def show
    @topic = Topic.find params[:id]
    last_page = @topic.last_page
    @replies = @topic.replies.asc(:created_at).paginate :per_page => 20, :page => (params[:page] || last_page )
    user_ids = @replies.map{|reply| reply.user_id}.push(@topic.user_id).flatten.compact.uniq
    @user_hash = User.create_user_hash(user_ids)

    if current_logined?
      current_user.read_topic @topic
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

  def mute
    @topic = Topic.find params[:id]
    @topic.mute_by current_user
    redirect_to @topic
  end

  def unmute
    @topic = Topic.find params[:id]
    @topic.unmute_by current_user
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

  def filter_tab(tab)
    if current_logined?
      allow_list = %w( active newest interesting own replied collection )
    else
      allow_list = %w( active newest )
    end
    allow_list.include?(tab) ? tab : nil
  end
end
