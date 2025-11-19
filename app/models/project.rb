class Project < ApplicationRecord
  belongs_to :tenant

  # File attachments
  has_one_attached :pdf_file
  has_many_attached :images

  # Associations
  has_many :artifacts, dependent: :destroy
  has_many :user_projects, dependent: :destroy
  has_many :users, through: :user_projects

  # Validations
  validates :title, uniqueness: true
  validate :free_plan_can_have_only_one_project, on: :create

  # -------------------------
  # Class Methods
  # -------------------------

  # Returns projects accessible by a tenant depending on the plan
  def self.by_plan_and_tenant(tenant_id)
    tenant = Tenant.find(tenant_id)
    if tenant.plan == 'premium'
      tenant.projects
    else
      tenant.projects.order(:id).limit(1)
    end
  end

  # Returns projects accessible by a specific user within a tenant
  def self.by_user_plan_and_tenant(tenant_id, user)
    tenant = Tenant.find(tenant_id)

    if tenant.plan == 'premium'
      user.is_admin? ? tenant.projects : user.projects.where(tenant_id: tenant.id)
    else
      if user.is_admin?
        tenant.projects.order(:id).limit(1)
      else
        user.projects.where(tenant_id: tenant.id).order(:id).limit(1)
      end
    end
  end

  # -------------------------
  # Instance Methods
  # -------------------------

  private

  # Ensure free tenants can create only one project
  def free_plan_can_have_only_one_project
    if tenant.plan == 'free' && tenant.projects.exists?
      errors.add(:base, "Free plans cannot have more than one project")
    end
  end
end