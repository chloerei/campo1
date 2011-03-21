module TopicsHelper

  Tabs = %w( active interesting own newest replied collection tagged search notifications )
  def direction_for(current, tab)
    current_index = Tabs.index(current.to_s)
    return if current_index.nil?
    index = Tabs.index(tab)
    if current_index > index
      return 'left'
    elsif current_index < index
      return 'right'
    else
      return nil
    end
  end

  def show_admin_link?
    params[:manage] == 'true' and current_admin?
  end

  def switch_admin_mode
    if show_admin_link?
      link_to t('topics.normal_mode'), url_for(:page => params[:page])
    else
      link_to t('topics.admin_mode'), url_for(:manage => 'true', :page => params[:page])
    end
  end
end
