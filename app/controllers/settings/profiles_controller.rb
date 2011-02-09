class Settings::ProfilesController < ApplicationController
  before_filter :require_logined

  def show
    @profile = current_user.profile
  end

  def update
    @profile = current_user.profile
    if @profile.update_attributes params[:profile]
      flash[:success] = "Successful update profile"
      redirect_to :action => :show
    else
      render :show
    end
  end
end
