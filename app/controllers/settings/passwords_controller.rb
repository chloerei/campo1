class Settings::PasswordsController < ApplicationController
  before_filter :require_logined

  def show
    @user = current_user
  end
  
  def update
    @user = current_user
    if @user.update_attributes :password => params[:user][:password],
                               :password_confirmation => params[:user][:password_confirmation],
                               :current_password => params[:user][:current_password]
      flash[:success] = "Successful update password"
      redirect_to :action => :show
    else
      render :show
    end
  end
end
