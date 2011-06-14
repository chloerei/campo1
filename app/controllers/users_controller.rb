class UsersController < ApplicationController
  before_filter :require_not_logined
  layout 'login'

  def new
    @user = User.new
  end

  def create
    @user = User.new params[:user]
    if @user.save
      login_as @user
      set_remember_cookie if params[:user][:remember_me] == "1"
      redirect_to root_url
    else
      render :new
    end
  end

end
