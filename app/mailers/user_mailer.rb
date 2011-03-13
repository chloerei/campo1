class UserMailer < ActionMailer::Base
  default :from => "from@example.com"
  default_url_options[:host] = APP_CONFIG['host']

  def reset_password_token(user)
    @user = user
    mail :to => user.email,
         :subject => I18n.t('user_mailer.reset_password_token.title', :name => APP_CONFIG['site_name'])
  end
end
