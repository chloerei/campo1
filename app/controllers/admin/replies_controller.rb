class Admin::RepliesController < Admin::BaseController
  def index
    @replies = Reply.desc(:created_at).paginate :per_page => 20, :page => params[:page]
    user_ids = @replies.map{|reply| reply.user_id}.flatten.compact.uniq
    @user_hash = User.create_user_hash(user_ids)
  end

  def show
    @reply = Reply.find params[:id]
  end

  def destroy
    @reply = Reply.find params[:id]
    @reply.destroy
    redirect_to :action => :index
  end
end
