class Admin::BaseController < ApplicationController
  layout 'admin'
  before_filter :require_logined, :require_admin

  protected

  def require_admin
    render_422 unless APP_CONFIG['admin_emails'].include? current_user.email
  end
end
