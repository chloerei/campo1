module TopicsHelper
  def show_admin_link?
    params[:manage] == 'true' and current_admin?
  end

  def switch_admin_mode
    if show_admin_link?
      link_to t(:normal_mode), url_for(:page => params[:page])
    else
      link_to t(:admin_mode), url_for(:manage => 'true', :page => params[:page])
    end
  end
end
