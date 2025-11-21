class AddPlanToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :plan, :string
  end
end
