class Settings::PasswordsController < ApplicationController
  before_filter :require_logined

  def show
    set_page_title I18n.t :settings_password
    @user = current_user
  end
  
  def update
    @user = current_user
    if @user.update_attributes :password => params[:user][:password],
                               :password_confirmation => params[:user][:password_confirmation],
                               :current_password => params[:user][:current_password]
      flash[:success] = I18n.t :successful_update
      redirect_to :action => :show
    else
      set_page_title I18n.t :settings_password
      render :show
    end
  end
end
