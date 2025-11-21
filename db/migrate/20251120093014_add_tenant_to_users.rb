class AddTenantToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :tenant, foreign_key: true, index: true, null: true
  end
end