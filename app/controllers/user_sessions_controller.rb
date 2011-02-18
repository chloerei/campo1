class UserSessionsController < ApplicationController
  def new
    set_page_title I18n.t :login
  end

  def create
    @user = User.authenticate params[:user][:login], params[:user][:password]
    if @user
      login_as @user
      set_remember_cookie if params[:user][:remember_me] == "1"
      logger.info params[:return_to]
      redirect_back_or_default params[:return_to] || root_url
    else
      set_page_title I18n.t :login
      flash[:error] = I18n.t :login_fail
      redirect_to login_url
    end
  end

  def destroy
    logout
    redirect_to root_url
  end
end
