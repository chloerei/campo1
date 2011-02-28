class Admin::UsersController < Admin::BaseController
  def index
    @users = User.desc(:created_at).paginate :per_page => 20, :page => params[:page]
  end

  def show
    @user = User.find params[:id]
  end

  def destroy
    @user = User.find params[:id]
    @user.destroy
    redirect_to :action => :index
  end
end
