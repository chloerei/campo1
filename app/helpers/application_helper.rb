module ApplicationHelper
  def page_title
   @page_title.present? ? "#{@page_title} - #{APP_CONFIG['site_name']}" : APP_CONFIG['site_name']
  end

  def smart_time_string(time)
    time < 1.week.ago ? l(time, :format => :long) : "#{time_ago_in_words time} #{t :ago}"
  end

  def show_head_html?
    !!@show_head_html and site_config.layout.head_html.present?
  end

  def show_sidebar_bottom_html?
    !!@show_sidebar_bottom_html and site_config.layout.sidebar_bottom_html.present?
  end

  def rich_content(content)
    sanitize Redcarpet.new(content, :hard_wrap, :autolink, :no_intraemphasis).to_html
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
