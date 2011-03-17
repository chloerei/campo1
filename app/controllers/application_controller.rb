#encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :current_logined?, :current_admin?, :page_title, :topic_url_with_last_anchor, :site_config

  rescue_from Exception, :with => :render_500
  rescue_from Mongoid::Errors::DocumentNotFound, :with => :render_404
  rescue_from BSON::InvalidObjectId, :with => :render_404

  before_filter :set_locale
 
  protected

  attr_writer :show_head_html, :show_sidebar_bottom_html

  def site_config
    @site_config ||= SiteConfig.first
  end

  def set_locale
    I18n.locale = extract_locale_from_user_config || extract_locale_from_accept_language_header || I18n.default_locale
  end

  def extract_locale_from_user_config
    return unless current_logined?
    AllowLocale.include?(current_user.locale) ? current_user.locale : nil
  end

  def extract_locale_from_accept_language_header
    request.compatible_language_from(AllowLocale)
  end

  def topic_url_with_last_anchor(topic)
    anchor = (topic.replies_count == 0 ? nil : "replies-#{topic.replies_count}")
    topic_url(topic, :anchor => anchor)
  end

  def render_404(exception = nil)
    if exception
        logger.info "Rendering 404: #{exception.message}"
    end

    set_page_title "404"
    render 'errors/404', :layout => 'login', :status => 404
  end

  def render_422(exception = nil)
    if exception
        logger.info "Rendering 422: #{exception.message}"
    end

    set_page_title "422"
    render 'errors/422', :layout => 'login', :status => 422
  end

  def render_500(exception = nil)
    if exception
        logger.info "Rendering 500: #{exception.message}"
    end

    set_page_title "500"
    render 'errors/500', :layout => 'login', :status => 500
  end

  def current_admin?
    current_logined? and current_user.admin?
  end

  def set_page_title(value)
    @page_title = value
  end

  def page_title
    if defined? @page_title
      "#{APP_CONFIG['site_name']} › #{@page_title}"
    else
      APP_CONFIG['site_name']
    end
  end

  def require_user_not_banned
    if current_logined? and current_user.banned?
      render_422
    end
  end

  def require_logined
    if !current_logined?
      flash[:notice] = I18n.t :_require_login
      store_location
      redirect_to login_url
    end
  end

  def require_not_logined
    redirect_to root_url if current_logined?
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
    @current_user ||= login_form_session || login_from_cookies || false if @current_user != false
    @current_user
  end

  def current_user=(user)
    @current_user = user
    session[:user_id] = user ? user.id : nil
  end

  def login_as(user)
    self.current_user = user
  end

  def logout
    current_user.forget_me
    self.current_user = nil
    kill_remember_cookie
  end

  def login_form_session
    User.find session[:user_id] if session[:user_id]
  rescue
    nil
  end

  def login_from_cookies
    user = User.first :conditions => {:remember_token => cookies[:auth_token]} if cookies[:auth_token]
    if user and user.remember_token?
      user
    else
      kill_remember_cookie if cookies[:auth_token]
      nil
    end
  end

  def kill_remember_cookie
    cookies.delete :auth_token
  end

  def set_remember_cookie
    return if !current_logined?

    current_user.remember_me
    cookies[:auth_token] = {
      :value   => current_user.remember_token,
      :expires => current_user.remember_token_expires_at }
  end
end
