class PeopleController < ApplicationController
  respond_to :html, :rss, :only => [:topics]
  before_filter :layout_config, :find_person, :check_banned
  before_filter :require_logined, :except => [:show, :statuses, :topics, :followings, :followers]

  def show
    @statuses = @person.statuses.desc(:created_at).limit(5)
  end

  def statuses
    @statuses = @person.statuses.desc(:created_at).paginate :per_page => 20, :page => params[:page]
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
    @person.add_follower current_user
    redirect_to person_url(:username => @person.username)
  end

  def unfollow
    @person.remove_follower current_user
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
end
