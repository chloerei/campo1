class StatusesController < ApplicationController
  before_filter :require_logined, :only => [:own]
  def index
    @statuses = if current_logined?
                  current_user.stream.fetch_statuses :page => params[:page]
                else
                  Status::Base.desc(:created_at).paginate :page => params[:page], :per_page => 20
                end
  end

  def show
    @status = Status::Base.find params[:id]
  end

  def own
    @statuses = current_user.statuses.desc(:created_at).paginate :per_page => 20, :page => params[:page]
    render :index
  end

  def all
    @statuses  = Status::Base.desc(:created_at).paginate :page => params[:page], :per_page => 20
    render :index
  end
end
