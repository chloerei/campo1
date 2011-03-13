class Settings::FavoriteTagsController < ApplicationController
  before_filter :require_logined

  def show
    @favorite_tags = current_user.favorite_tags
    set_page_title I18n.t 'settings.favorite_tags.title'
  end

  def create
    current_user.add_favorite_tags params[:tags]
    redirect_to params[:return_to] || {:action => :show}
  end

  def destroy
    current_user.remove_favorite_tags params[:tags]
    redirect_to params[:return_to] || {:action => :show}
  end
end
