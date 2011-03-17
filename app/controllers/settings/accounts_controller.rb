class Settings::AccountsController < ApplicationController
  before_filter :require_logined, :except => [:new, :create]

  def show
    @user = current_user
    set_page_title I18n.t 'settings.accounts.title'
  end

  def update
    @user = User.find current_user.id
    params[:user].delete(:password)
    params[:user].delete(:password_confirmation)
    if @user.update_attributes params[:user]
      flash[:success] = I18n.t '.settings.accounts.update.flash_success', :locale => @user.locale
      redirect_to :action => :show
    else
      set_page_title I18n.t 'settings.accounts.title'
      render :show
    end
  end
end
