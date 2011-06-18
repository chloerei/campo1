class PeopleController < ApplicationController
  respond_to :html, :rss, :only => [:topics]
  before_filter :layout_config, :find_person, :check_banned
  before_filter :require_logined, :except => [:show, :statuses, :topics, :followings, :followers]

  def show
    @statuses = @person.statuses.desc(:created_at).limit(5)
    prepare_status_index
  end

  def statuses
    @statuses = @person.statuses.desc(:created_at).paginate :per_page => 20, :page => params[:page]
    prepare_status_index
  end

  def topics
    @topics = @person.topics.desc(:created_at).paginate(:per_page => 20, :page => params[:page])
    user_ids = @topics.map{|topic| topic.last_replied_by_id}.compact.uniq
    @user_hash = User.create_user_hash(user_ids)
    @user_hash[@person.id] = @person

    respond_with(@topics) do |format|
      format.html
      format.rss do
        @user_hash[@person.id] = @person
        @channel_link = person_url(:username => @person.username)
        render 'topics/topics', :layout => false
      end
    end
  end

  def followings
    @followings = @person.followings.paginate :per_page => 20, :page => params[:page]
  end

  def followers
    @followers = @person.followers.paginate :per_page => 20, :page => params[:page]
  end

  def follow
    current_user.follow @person
    redirect_to person_url(:username => @person.username)
  end

  def unfollow
    current_user.unfollow @person
    redirect_to person_url(:username => @person.username)
  end

  protected
  def layout_config
    self.show_head_html = true
  end

  def find_person
    @person = User.first :conditions => {:username => /^#{params[:username]}$/i}
    raise Mongoid::Errors::DocumentNotFound.new(User, params[:username]) if @person.nil?
  end

  def check_banned
    render :banned, :status => 403 if @person.banned?
  end

  def prepare_status_index
    topic_ids = @statuses.map{|status| status.topic_id if status.respond_to?(:topic_id) }.compact.uniq
    reply_ids = @statuses.map{|status| status.reply_id if status.respond_to?(:reply_id) }.compact.uniq
    user_ids  = @statuses.map(&:user_id).compact

    @topic_hash = Topic.create_topic_hash(topic_ids)
    @reply_hash = Reply.create_reply_hash(reply_ids)
    @user_hash  = User.create_user_hash(user_ids)
  end
end
