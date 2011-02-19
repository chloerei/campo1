class UsersController < ApplicationController
  before_filter :require_not_logined
  layout 'login'

  def new
    @user = User.new
    set_page_title I18n.t :signup
  end

  def create
    @user = User.new params[:user]
    if @user.save
      flash[:success] = I18n.t :successful_signup
      login_as @user
      set_remember_cookie if params[:user][:remember_me] == "1"
      redirect_to root_url
    else
      set_page_title I18n.t :signup
      render :new
    end
  end

end
