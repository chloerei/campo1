class Profile
  include Mongoid::Document

  field :name
  field :url
  field :twitter
  field :description

  attr_accessible :name, :url, :twitter, :description

  embedded_in :user, :inverse_of => :profile
  validates_length_of :name, :in => 3..20
  validates_length_of :url, :maximum => 100, :alow_blank => true
  validates_length_of :twitter, :maximum => 15, :alow_blank => true
  validates_length_of :description, :maximum => 300, :alow_blank => true
end
