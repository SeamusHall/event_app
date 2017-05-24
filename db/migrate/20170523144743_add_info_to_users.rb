class AddInfoToUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :orders, :first_name
    remove_column :orders, :last_name
    remove_column :order_products, :first_name
    remove_column :order_products, :last_name

    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :address, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :postal_code, :string
    add_column :users, :phone, :string
    add_column :users, :country, :string
  end
end
