class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
   has_many :tenants
   has_many :user_projects
   has_many :projects, through: :user_projects
   belongs_to :tenant
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
  has_one :payment
  accepts_nested_attributes_for :payment
  has_many :images


  def  is_admin?
    is_admin
  end
end
