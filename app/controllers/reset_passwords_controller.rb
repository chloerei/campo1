class ResetPasswordsController < ApplicationController
  before_filter :require_not_logined
  layout 'login'

  def new
  end

  def create
    if params[:email].present?
      User.send_reset_password_instructions :email => params[:email]
    else
      render :new
    end
  end

  def show
    if params[:token] && @user = User.first(:conditions => {:reset_password_token => params[:token]})
    else
      render_422
    end
  end

  def update
    if params[:token] && @user = User.first(:conditions => {:reset_password_token => params[:token]})
      if @user.reset_password params[:new_password], params[:new_password_confirmation]
        flash[:success] = I18n.t :successful_reset_password
        login_as @user
        redirect_to root_url
      else
        render :show
      end
    else
      render_422
    end
  end
end
