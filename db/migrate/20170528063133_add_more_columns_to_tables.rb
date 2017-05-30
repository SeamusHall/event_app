class AddMoreColumnsToTables < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :comments, :text
    add_column :products, :tax, :decimal
  end
end
