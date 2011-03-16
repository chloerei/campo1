class SiteConfig
  include Mongoid::Document

  embeds_one :layout, :class_name => 'SiteConfig::Layout'

  before_create :build_layout
end
