class StatusesController < ApplicationController
  before_filter :require_logined, :only => [:own]
  before_filter :layout_config
  def index
    @statuses = if current_logined?
                  @tab = filter_tab(params[:tab]) || filter_tab(session[:statuses_tab])
                  session[:statuses_tab] = @tab
                  case @tab
                  when 'all'
                    Status::Base.desc(:created_at).paginate :page => params[:page], :per_page => 20
                  when 'own'
                    current_user.statuses.desc(:created_at).paginate :per_page => 20, :page => params[:page]
                  else
                    current_user.stream.fetch_statuses :page => params[:page]
                  end
                else
                  Status::Base.desc(:created_at).paginate :page => params[:page], :per_page => 20
                end
    prepare_index
  end

  def show
    @status = Status::Base.find params[:id]
    @user_hash = @topic_hash = @reply_hash = {}
    @user_hash[@status.user_id] = @status.user
    @topic_hash[@status.topic_id] = @status.topic if @status.respond_to?(:topic)
    @reply_hash[@status.reply_id] = @status.reply if @status.respond_to?(:reply)
  end

  private
  
  def filter_tab(tab)
    %w( feed own all ).include?(tab) ? tab : nil
  end

  def layout_config
    self.show_head_html = true
    self.show_sidebar_bottom_html = true
  end

  def prepare_index
    topic_ids = @statuses.map{|status| status.topic_id if status.respond_to?(:topic_id) }.compact.uniq
    reply_ids = @statuses.map{|status| status.reply_id if status.respond_to?(:reply_id) }.compact.uniq
    user_ids  = @statuses.map(&:user_id).compact

    @topic_hash = Topic.create_topic_hash(topic_ids)
    @reply_hash = Reply.create_reply_hash(reply_ids)
    @user_hash  = User.create_user_hash(user_ids)
  end
end
