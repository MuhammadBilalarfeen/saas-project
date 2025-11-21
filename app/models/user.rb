class User < ApplicationRecord
   has_many :owned_tenants, class_name: 'Tenant', foreign_key: 'user_id', inverse_of: :owner  # <- optional, because a new user might not have a tenant yet
     belongs_to :tenant, optional: true
     
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  has_many :user_projects
  has_many :projects, through: :user_projects
  has_one :payment
  has_many :images

  accepts_nested_attributes_for :payment

 def after_confirmation
  send_reset_password_instructions
end


  def is_admin?
    is_admin
  end
end