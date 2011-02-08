class UsersController < ApplicationController
  before_filter :require_not_logined, :only => [:new, :create]
  before_filter :require_logined, :except => [:new, :create]
  def new
    @user = User.new
  end

  def create
    @user = User.new params[:user]
    if @user.save
      flash[:success] = "Successful Signup"
      login_as @user
      redirect_to account_url
    else
      render :new
    end
  end

  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes params[:user]
      flash[:success] = "Successful update account"
      redirect_to account_url
    else
      render :show
    end
  end
end
