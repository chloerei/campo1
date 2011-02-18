class Settings::ProfilesController < ApplicationController
  before_filter :require_logined

  def show
    @profile = current_user.profile
  end

  def update
    @profile = current_user.profile
    if @profile.update_attributes params[:profile]
      flash[:success] = I18n.t :successful_update
      redirect_to :action => :show
    else
      render :show
    end
  end
end
