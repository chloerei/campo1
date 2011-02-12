class TopicsController < ApplicationController
  def index
    @topics = Topic.skip(params[:skip]).limit(20)
  end

  def show
    
  end
end
