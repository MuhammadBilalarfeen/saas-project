class Member < ApplicationRecord
  # Associations
  # If a member belongs to a user or tenant, add:
  # belongs_to :user
  # belongs_to :tenant

  # Validations
  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true
end