class OrderProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :order_products do |t|
      t.references :user, foreign_key: true
      t.decimal :total, precision: 9, scale: 2
      t.string :status
      t.text :payment_details
      t.string :first_name
      t.string :last_name
      t.string :auth_code
      t.string :transaction_id
      t.datetime :placed_at
      t.datetime :finalized_on

      t.timestamps
    end
  end
end
