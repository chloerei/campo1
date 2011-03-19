class InitUserAccessToken < Mongoid::Migration
  def self.up
    User.where(:access_token => {"$exists" => false}).each do |user|
      user.reset_access_token
      user.save
    end
  end

  def self.down
  end
end
