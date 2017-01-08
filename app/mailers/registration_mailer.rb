class RegistrationMailer < ActionMailer::Base
  default from: APP_CONFIG['site_email']
  layout 'mailer'
  
  def fb_registration_email(user_id)
    @user = User.find user_id
    @url = APP_CONFIG['sing_in_url']
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: @user.email, subject: 'Welcome to RidingSocial')
  end
end
