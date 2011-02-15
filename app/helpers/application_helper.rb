module ApplicationHelper
  def paginate_for(collection, options = {})
    locals = options.merge :collection => collection
    render :partial => 'share/paginate', :locals => locals
  end

  def link_to_person(user)
    link_to user.profile.name, person_url(:username => user.username)
  end
end
