class MailPreview < MailView

  def subscription
    NotificationMailer.subscription(User.first.id)
  end

  def expiration
    NotificationMailer.cc_expiration(User.first.id)
  end

  def suspension
    NotificationMailer.subscription_suspended(User.first.id)
  end

  def operation
    NotificationMailer.cc_operation(User.first.id, 99.99, "description", "reason")
  end

  def share_via_email
    NotificationMailer.share_route_via_email(User.first.id, 'user@domain.com', 438)
  end

  def registration
    RegistrationMailer.fb_registration_email(User.first.id)
  end

  def invoice
    NotificationMailer.cc_invoice(User.first.id, 123, 123, 'Bronze', 7.99)
  end

  def invite_to_admin
    NotificationMailer.invite_to_admin('user@example.com', 'John Doe', 777)
  end

  def copy_route
    NotificationMailer.copy_route(User.first.id, User.last.id, 438)
  end

  def unsubscribe_to_admins
    NotificationMailer.unsubscription_to_admins(User.where.not(subscription_id: nil).first.id)
  end

  ## Factory-like pattern
  #def welcome
  #  user = User.create!
  #  mail = Notifier.welcome(user)
  #  user.destroy
  #  mail
  #end
  #
  ## Stub-like
  #def forgot_password
  #  user = Struct.new(:email, :name).new('name@example.com', 'Jill Smith')
  #  mail = UserMailer.forgot_password(user)
  #end

  private
  def user(email='name@example.com', name='Jill Smith')
    Struct.new(:email, :full_name).new(email, name)
  end

  def route
    Struct.new(:id).new(999)
  end

end
