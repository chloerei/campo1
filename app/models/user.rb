class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Gravtastic
  include TagParser
  gravtastic :rating => 'G', :size => 48

  field :username
  field :email
  field :locale
  field :crypted_password
  field :password_salt
  field :remember_token
  field :remember_token_expires_at, :type => Time
  field :favorite_tags, :type => Array
  field :banned, :type => Boolean
  field :reset_password_token
  embeds_one :profile
  embeds_many :notifications, :class_name => 'Notification::Base'
  
  references_many :topics, :validate => false
  references_many :replies, :validate => false

  validates_presence_of :username, :email
  validates_presence_of :password, :if => Proc.new {|user| user.requrie_password?}
  validates_presence_of :current_password, :if => Proc.new {|user| user.require_current_password?}
  validates_length_of :password, :minimum => 6, :allow_blank => true
  validates_uniqueness_of :username, :email, :case_sensitive => false
  UsernameRegex = /\A\w{3,20}\z/
  validates_format_of :username, :with => UsernameRegex
  validates_format_of :locale, :with => /\A(#{AllowLocale.join('|')})\Z/, :allow_blank => true

  EmailNameRegex  = '[\w\.%\+\-]+'
  DomainHeadRegex = '(?:[A-Z0-9\-]+\.)+'
  DomainTldRegex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  EmailRegex       = /\A#{EmailNameRegex}@#{DomainHeadRegex}#{DomainTldRegex}\z/i
  validates_format_of :email, :with => EmailRegex
  validates_length_of :email, :maximum => 100

  attr_accessor :password, :password_confirmation, :current_password
  attr_accessible :login, :username, :email, :locale, :password, :password_confirmation, :current_password

  before_save :prepare_password
  before_create :init_profile
  before_destroy :clean!

  validate :check_password, :check_current_password, :check_favorite_tags

  def send_notification(attributes = {}, klass = nil)
    if notifications.size >= 50
      ids = notifications.asc(:created_at).slice(0..-50).map(&:id)
      collection.update({:_id => self.id},
                        {'$pull' => {:notifications => {:_id => {'$in' => ids}}}} )
      # TODO : user.notifications need sync
    end

    notifications.create attributes, klass
  end

  def read_topic(topic)
    if notifications.where({:topic_id => topic.id, :_type => 'Notification::Mention'}).count != 0
      collection.update({:_id => self.id},
                        {'$pull' => {:notifications => {:topic_id => topic.id, :_type => 'Notification::Mention'}}} )
      # TODO : another way to sync user.notifications without object reload
      reload
    end
  end

  def admin?
    APP_CONFIG['admin_emails'].include? self.email
  end

  def ban!
    self.banned = true
    save
  end

  def unban!
    self.banned = false
    save
  end

  def clean!
    self.replies.delete_all
    topic_ids = self.topics.only(:id).to_a.map{|topic| topic.id}
    Reply.delete_all :conditions => {:topic_id => {"$in" => topic_ids}}
    self.topics.delete_all
  end
  
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

  def self.send_reset_password_instructions(attributes = {})
    return if attributes[:email].blank?

    user = User.first :conditions => {:email => /^#{attributes[:email]}$/i}
    user && user.send_reset_password_instructions
  end

  def send_reset_password_instructions
    make_reset_password_token
    UserMailer.reset_password_token(self).deliver
  end

  def make_reset_password_token
    self.reset_password_token = make_token
    save(:validate => false)
  end

  def reset_password(new_password, new_password_confirmation)
    self.password = new_password
    self.password_confirmation = new_password_confirmation
    @recovering = true
    self.reset_password_token = nil if valid?
    save
  end

  protected

  def make_token
    User.secure_digest(Time.now, (1..10).map{ rand.to_s }, self.username, self.email)
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token            = make_token
    self.remember_token_expires_at = time
    save
  end

  def init_profile
    self.build_profile :name => self.username
  end

  def check_password
    if self.password.present?
      errors.add(:password_confirmation, I18n.t('user.errors.password_confirmation_not_match')) unless self.password == self.password_confirmation
    end
  end

  def check_current_password
    if require_current_password?
      errors.add(:current_password, I18n.t('user.errors.current_password_not_match')) unless self.matching_password?(self.current_password)
    end
  end

  def check_favorite_tags
    if favorite_tags and favorite_tags.count > 50
      errors.add(:favorite_tags, I18n.t('user.errors.favorite_tags_size'))
    end
  end

  def requrie_password?
    new_record? or @recovering
  end

  def require_current_password?
    !new_record? and !@recovering and (password.present? or email_changed? or username_changed?)
  end

  def prepare_password
    unless password.blank?
      self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.crypted_password = encrypt_password(self.password) 
      self.password = self.password_confirmation = nil
    end
  end

  def encrypt_password(password)
    digest = [password, self.password_salt].flatten.join('')
    20.times { digest = User.secure_digest(digest) }
    digest
  end
  
  def self.secure_digest(*args)
    Digest::SHA512.hexdigest(args.flatten.join)
  end
end
