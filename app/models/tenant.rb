class Tenant < ApplicationRecord
  has_many :users
  has_many :projects, dependent: :destroy
  has_one :payment
  accepts_nested_attributes_for :payment


  cattr_accessor :current_tenant

  def self.set_current_tenant(tenant)
    self.current_tenant = tenant
  end

  def self.current
    self.current_tenant
  end

   def can_create_projects?
    (plan == 'free' && projects.count < 1) || (plan == 'premium')
  end
end