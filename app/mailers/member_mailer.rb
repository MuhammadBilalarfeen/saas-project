class MemberMailer < ApplicationMailer
  def invite_email(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: "You're invited to SaasProjectApp!")
  end
end