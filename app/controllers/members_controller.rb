class MembersController < ApplicationController
  before_action :authenticate_user!

  def new
    @member = Member.new
  end

  def create
    # Check if member already exists
    @member = Member.find_by(email: member_params[:email])
    unless @member
      @member = Member.create(member_params)
    end

    # Check if user exists
    @user = User.find_by(email: @member.email)
    unless @user
      @user = User.create(email: @member.email, password: Devise.friendly_token[0, 20])
    end

    # Send Devise reset password instructions (invite)
    @user.send_reset_password_instructions

    redirect_to members_path, notice: "Invite sent successfully to #{@user.email}"
  end

  private

  def member_params
    params.require(:member).permit(:first_name, :last_name, :email)
  end
end