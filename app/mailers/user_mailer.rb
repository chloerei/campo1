class UserMailer < ActionMailer::Base
  default :from => "from@example.com"

  def reset_password_token(user)
    @user = user
    mail :to => user.email,
         :subject => I18n.t('mailer.reset_password_token.title')
  end
end
