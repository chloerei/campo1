class CreateSiteConfig < Mongoid::Migration
  def self.up
    site_config = SiteConfig.create
  end

  def self.down
    SiteConfig.delete_all
  end
end
