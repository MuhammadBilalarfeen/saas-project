class AddCardDetailsToPayments < ActiveRecord::Migration[8.1]
  def change
    add_column :payments, :card_number, :string
    add_column :payments, :card_cvv, :string
    add_column :payments, :card_expires_month, :integer
    add_column :payments, :card_expires_year, :integer
  end
end
