module ApplicationHelper
  def rich_content(content)
    sanitize RDiscount.new(content).to_html
  end

  def paginate_for(collection, options = {})
    locals = options.merge :collection => collection
    render :partial => 'share/paginate', :locals => locals
  end

  def link_to_person(user)
    link_to user.profile.name, person_url(:username => user.username), :title => "#{user.profile.name}'s person page"

  end

  def link_gravatar_to_person(user, options = {})
    options[:size] ||= 48
    link_to image_tag(user.gravatar_url(:size => options[:size]), :alt => "#{user.profile.name}'s gravatar"), person_url(:username => user.username), :title => "#{user.profile.name}'s person page"
  end
end
