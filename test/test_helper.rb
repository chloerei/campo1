ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  
  def create_user
    User.create :username => 'test', :email => 'test@test.com', :password => '12345678', :password_confirmation => '12345678'
  end

  def create_admin
    User.create :username => 'admin', :email => 'admin@codecampo.com', :password => '12345678', :password_confirmation => '12345678'
  end
  
  def login_as(user)
    @controller.send 'login_as', user
  end

  def current_user
    @controller.send :current_user
  end

  # Drop all columns after each test case.
  def teardown
    Mongoid.database.collections.each do |coll|
      coll.remove
    end
  end

  # Make sure that each test case has a teardown
  # method to clear the db after each test.
  def inherited(base)
    base.define_method teardown do
      super
    end
  end
end
