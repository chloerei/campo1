class Settings::FavoriteTagsController < ApplicationController
  before_filter :require_logined

  def show
    @favorite_tags = current_user.favorite_tags
  end

  def create
    current_user.add_favorite_tags params[:tags]
    current_user.save
    redirect_to :action => :show
  end
end
