class PeopleController < ApplicationController
  def show
    @person = User.first :conditions => {:username => /^#{params[:username]}$/i}
  end
end
