class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :current_logined?
  
  protected

  def require_logined
    if !current_logined?
      flash[:notice] = "require login"
      store_location
      redirect_to login_url
    end
  end

  def require_not_logined
    redirect_to root_url if current_logined? # TODO redirect to public profile page
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def current_logined?
    !!current_user
  end

  def current_user
    @current_user ||= login_form_session || false if @current_user != false
    @current_user
  end

  def current_user=(user)
    @current_user = user || false
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
