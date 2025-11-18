class Project < ApplicationRecord
  belongs_to :tenant
   has_one_attached :pdf_file
  has_many_attached :images
  has_many :artifacts, dependent: :destroy

  validates :title, uniqueness: true
  validate :free_plan_can_have_only_one_project, on: :create

  private

  def free_plan_can_have_only_one_project
    if tenant.plan == 'free' && tenant.projects.exists?
      errors.add(:base, "Free plans cannot have more than one project")
    end
  end

  def self.by_plan_and_tenant(tenant_id)
    tenant = Tenant.find(tenant_id)
    if tenant.plan == 'premium'
      tenant.projects
    else
      tenant.projects.order(:id).limit(1)
    end
  end
end