class CreateSiteConfig < Mongoid::Migration
  def self.up
    SiteConfig.find_or_initialize_by
  end

  def self.down
    SiteConfig.delete_all
  end
end
