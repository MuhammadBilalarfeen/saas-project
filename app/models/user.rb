class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
   has_many :tenants
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :payment
  accepts_nested_attributes_for :payment
  has_many :images
end
