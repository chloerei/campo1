class Settings::FavoriteTagsController < ApplicationController
  before_filter :require_logined
  respond_to :html, :js, :only => [:create, :destroy]

  def show
    @favorite_tags = current_user.favorite_tags
  end

  def create
    @new_tags = current_user.parse_tags_from_string(params[:tags]) - current_user.favorite_tags.to_a
    current_user.favorite_tags ||= []
    current_user.favorite_tags += @new_tags
    current_user.save

    respond_with @new_tags do |format|
      format.html do
        flash[:error] = current_user.errors.full_messages.first if !current_user.valid?
        redirect_to params[:return_to] || url_for(:action => :show)
      end
      format.js { render :layout => false } 
    end
  end

  def destroy
    @destroy_tags = current_user.parse_tags_from_string(params[:tags])
    current_user.favorite_tags -= @destroy_tags
    current_user.save
    respond_with @destroy_tags do |format|
      format.html do
        redirect_to params[:return_to] || {:action => :show}
      end
      format.js { render :layout => false } 
    end
  end
end
