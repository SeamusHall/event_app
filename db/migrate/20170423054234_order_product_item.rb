class OrderProductItem < ActiveRecord::Migration[5.0]
  def change
    create_table :order_product_items do |t|
      t.references :product, foreign_key: true
      t.references :order_product, foreign_key: true
      t.integer :quantity
      t.timestamps
    end
  end
end
