class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?
  
  protected

  def current_logined?
    !!current_user
  end

  def current_user
    @current_user ||= login_form_session || false if @current_user != false
    @current_user
  end

  def current_user=(user)
    @current_user = user || nil
    session[:user_id] = user ? user.id : nil
  end

  def login_as(user)
    self.current_user = user
  end

  def logout
    self.current_user = nil
  end

  def login_form_session
    User.find session[:user_id] if session[:user_id]
  rescue
    nil
  end
end
