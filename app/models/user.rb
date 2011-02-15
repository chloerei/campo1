class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Gravtastic
  gravtastic

  field :username
  field :email
  field :crypted_password
  field :password_salt
  field :remember_token
  field :remember_token_expires_at, :type => Time
  field :favorite_tags, :type => Array
  embeds_one :profile
  
  references_many :topics, :validate => false
  references_many :replies, :validate => false

  validates_presence_of :username, :email
  validates_uniqueness_of :username, :email, :case_sensitive => false
  validates_format_of :username, :with => /\A[A-Za-z0-9_]+\z/
  validates_length_of :username, :in => 3..20

  EmailNameRegex  = '[\w\.%\+\-]+'
  DomainHeadRegex = '(?:[A-Z0-9\-]+\.)+'
  DomainTldRegex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  EmailRegex       = /\A#{EmailNameRegex}@#{DomainHeadRegex}#{DomainTldRegex}\z/i
  validates_format_of :email, :with => EmailRegex
  validates_length_of :email, :maximum => 100

  attr_accessor :password, :password_confirmation, :current_password
  attr_accessible :login, :username, :email, :password, :password_confirmation, :current_password

  before_save :prepare_password
  after_create :init_profile

  validate :check_password, :check_current_password
  
  def self.authenticate(login, password)
    user = first(:conditions => {:username => /^#{login}$/i}) || first(:conditions => {:email => /^#{login}$/i})
    return user if user && user.matching_password?(password)
  end
  
  def matching_password?(password)
    self.crypted_password == encrypt_password(password)
  end

  def remember_me
    remember_me_for 4.weeks
  end

  def remember_token?
    remember_token and remember_token_expires_at and Time.now < remember_token_expires_at
  end

  def forget_me
    self.remember_token = nil
    self.remember_token_expires_at = nil
    save
  end

  def self.create_user_hash(user_ids)
    user_hash = {}
    users = User.where(:_id.in => user_ids)
    users.each{|user| user_hash[user.id] = user}
    user_hash
  end

  def add_favorite_tags(tags_string)
    self.favorite_tags ||= []
    self.favorite_tags += tags_string.split(" ")
    self.favorite_tags = self.favorite_tags.uniq
  end

  def remove_favorite_tags(tags_string)
    return if self.favorite_tags.nil?
    self.favorite_tags -= tags_string.split(" ")
    self.favorite_tags = nil if self.favorite_tags.empty?
  end

  protected

  def self.make_token
    User.digest(Time.now, 1, (1..10).map{ rand.to_s })
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token            = self.class.make_token
    self.remember_token_expires_at = time
    save
  end

  def init_profile
    self.create_profile :name => self.username
  end

  def check_password
    if new_record?
      errors.add(:password, "Password can't be blank") if self.password.blank?
      check_password_format
    elsif !self.password.blank?
      check_password_format
    end
  end

  def check_password_format
    errors.add(:password_confirmation, "Password and confirmation does not match") unless self.password == self.password_confirmation
    errors.add(:password, "Password must be at least 6 chars long") if self.password.to_s.size < 6
  end

  def check_current_password
    if require_current_password?
      errors.add(:current_password, "Please fill in Current Password") if self.current_password.blank?
      errors.add(:current_password, "Current Password not match") unless self.matching_password?(self.current_password)
    end
  end

  def require_current_password?
    !new_record? and (password.present? or email_changed? or username_changed?)
  end

  def prepare_password
    unless password.blank?
      self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.crypted_password = encrypt_password(self.password) 
      self.password = self.password_confirmation = nil
    end
  end

  def encrypt_password(password)
    User.digest(password, 20, self.password_salt)
  end
  
  def self.digest(password, stretches, salt)
    digest = [password, salt].flatten.join('')
    stretches.times { digest = Digest::SHA512.hexdigest(digest) }
    digest
  end
end
