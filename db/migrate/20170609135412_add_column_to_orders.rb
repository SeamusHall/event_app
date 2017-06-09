class AddColumnToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :send_message, :boolean
    add_column :order_products, :send_message, :boolean
  end
end
