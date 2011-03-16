class Settings::ProfilesController < ApplicationController
  before_filter :require_logined
  layout 'settings'

  def show
    set_page_title I18n.t 'settings.profiles.title'
    @profile = current_user.profile
  end

  def update
    @profile = current_user.profile
    if @profile.update_attributes params[:profile]
      flash[:success] = I18n.t 'settings.profiles.flash_success'
      redirect_to :action => :show
    else
      set_page_title I18n.t 'settings.profiles.title'
      render :show
    end
  end
end
