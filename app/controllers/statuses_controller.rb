class StatusesController < ApplicationController
  def index
    @statuses = if current_logined?
                  current_user.stream.fetch_statuses :page => params[:page]
                else
                  Status::Base.desc(:created_at).paginate :page => params[:page], :per_page => 20
                end
    @current = 'statuses'
  end
end
