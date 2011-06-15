class StatusesController < ApplicationController
  before_filter :require_logined, :only => [:own]
  def index
    @statuses = if current_logined?
                  @tab = filter_tab(params[:tab]) || filter_tab(session[:statuses_tab])
                  session[:statuses_tab] = @tab
                  case @tab
                  when 'all'
                    Status::Base.desc(:created_at).paginate :page => params[:page], :per_page => 20
                  when 'own'
                    @statuses = current_user.statuses.desc(:created_at).paginate :per_page => 20, :page => params[:page]
                  else
                    current_user.stream.fetch_statuses :page => params[:page]
                  end
                else
                  Status::Base.desc(:created_at).paginate :page => params[:page], :per_page => 20
                end
  end

  def show
    @status = Status::Base.find params[:id]
  end

  private
  
  def filter_tab(tab)
    %w( feed own all ).include?(tab) ? tab : nil
  end
end
