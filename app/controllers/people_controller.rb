class PeopleController < ApplicationController
  def show
    @person = User.first :conditions => {:username => /^#{params[:username]}$/i}
    @topics = @person.topics.desc(:created_at).limit(10)
    user_ids = @topics.map{|topic| topic.last_replied_by_id}.compact.uniq
    @user_hash = User.create_user_hash(user_ids)
  end
end
