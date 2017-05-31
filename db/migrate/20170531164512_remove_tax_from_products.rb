class RemoveTaxFromProducts < ActiveRecord::Migration[5.0]
  def change
    remove_column :products, :tax, :decimal
    remove_column :products, :price, :decimal

    change_table :products do |t|
      t.decimal :price, precision: 9, scale: 2
      t.decimal :tax, precision: 6, scale: 5
    end
  end
end
