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
end
