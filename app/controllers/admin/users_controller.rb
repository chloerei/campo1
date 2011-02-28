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

  def ban
    @user = User.find params[:id]
    @user.ban!
    redirect_to :action => :show, :id => @user.id
  end

  def unban
    @user = User.find params[:id]
    @user.unban!
    redirect_to :action => :show, :id => @user.id
  end

  def ban_and_clean
    @user = User.find params[:id]
    @user.ban!
    @user.clean!
    redirect_to :action => :show, :id => @user.id
  end
end
