class SiteConfig::Layout
  include Mongoid::Document

  embedded_in :site_config

  field :head_html
  field :sidebar_html
end
