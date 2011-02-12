class TopicsController < ApplicationController
  def index
    @topics = Topic.skip(params[:skip]).limit(20)
  end
end
