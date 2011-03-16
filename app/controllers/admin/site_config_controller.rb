class Admin::SiteConfigController < Admin::BaseController
  def show
    @site_config = site_config
  end

  def update
    @site_config = site_config
    if @site_config.update_attributes params[:site_config]
      redirect_to :action => :show
    else
      render :show
    end
  end
end
