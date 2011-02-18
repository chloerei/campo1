class PeopleController < ApplicationController
  def show
    @person = User.first :conditions => {:username => /^#{params[:username]}$/i}
    set_page_title @person.profile.name
    #TODO when person no found, throw Mongoid::Errors::DocumentNotFound
    @topics = @person.topics.desc(:created_at).limit(10)
    user_ids = @topics.map{|topic| topic.last_replied_by_id}.compact.uniq
    @user_hash = User.create_user_hash(user_ids)
  end

  def topics
    @person = User.first :conditions => {:username => /^#{params[:username]}$/i}
    set_page_title @person.profile.name
    @topics = @person.topics.desc(:created_at).paginate(:per_page => 20, :page => params[:page])
    user_ids = @topics.map{|topic| topic.last_replied_by_id}.compact.uniq
    @user_hash = User.create_user_hash(user_ids)
  end
end
