class Admin::BaseController < ApplicationController
  layout 'admin'
  before_filter :require_logined, :require_admin

  protected

  def require_admin
    render_422 unless current_user.admin?
  end
end
