module ApplicationHelper
  def paginate_for(collection, options = {})
    locals = options.merge :collection => collection
    render :partial => 'share/paginate', :locals => locals
  end
end
