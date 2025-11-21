class Tenant < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id', inverse_of: :owned_tenants

  has_many :users, dependent: :nullify
  has_many :projects, dependent: :destroy
  has_one :payment

  # Nested attributes for payment
  accepts_nested_attributes_for :payment,
                                update_only: true, # important to update instead of replacing
                                reject_if: ->(attrs) { attrs.values.all?(&:blank?) }

  # Thread-local current tenant
  def self.set_current_tenant(tenant)
    Thread.current[:current_tenant] = tenant
  end

  def self.current_tenant
    Thread.current[:current_tenant]
  end

  # Check if tenant can create more projects
  def can_create_projects?
    plan == 'free' ? projects.count < 1 : true
  end
end