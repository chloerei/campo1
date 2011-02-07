class User
  include Mongoid::Document

  field :username
  field :email
  field :nickname
  field :crypted_password
  field :password_salt

  validates_presence_of :username, :email
  validates_uniqueness_of :username, :email, :case_sensitive => false
  validates_format_of :username, :with => /\A[A-Za-z]+\z/
  validates_length_of :username, :in => 3..20
  validates_length_of :nickname, :in => 3..20, :allow_blank => true

  EmailNameRegex  = '[\w\.%\+\-]+'
  DomainHeadRegex = '(?:[A-Z0-9\-]+\.)+'
  DomainTldRegex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  EmailRegex       = /\A#{EmailNameRegex}@#{DomainHeadRegex}#{DomainTldRegex}\z/i
  EmailInvalidMessage = I18n.t(:it_dont_look_lick_a_email)
  validates_format_of :email, :with => EmailRegex
  validates_length_of :email, :maximum => 100

  attr_accessor :password, :password_confirmation, :current_password
  attr_accessible :login, :username, :nickname, :email, :password, :password_confirmation, :current_password

  before_save :prepare_password

  validate :check_password, :check_current_password
  
  def self.authenticate(login, password)
    user = first(:conditions => {:username => login}) || first(:conditions => {:email => login})
    return user if user && user.matching_password?(password)
  end
  
  def matching_password?(password)
    self.crypted_password == encrypt_password(password)
  end

  protected

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
    errors.add(:password, "Password must be at least 4 chars long") if self.password.size < 4
  end

  def check_current_password
    if require_current_password?
      errors.add(:current_password, "Please fill in Current Password") if self.current_password.blank?
      errors.add(:current_password, "Current Password not match") unless self.matching_password?(self.current_password)
    end
  end

  def require_current_password?
    !new_record? and password.present?
  end

  def prepare_password
    unless password.blank?
      self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.crypted_password = encrypt_password(self.password) 
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
