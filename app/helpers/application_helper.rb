module ApplicationHelper
  def paginate_for(collection)
    render :partial => 'share/paginate', :locals => {:collection => collection}
  end
end
