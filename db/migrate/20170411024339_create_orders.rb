class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true
      t.references :event_item, foreign_key: true
      t.integer :quantity
      t.decimal :total, precision: 9, scale: 2
      t.datetime :start_date
      t.datetime :end_date
      t.string :status
      t.text :comment
      t.text :payment_details
      t.string :first_name
      t.string :last_name
      t.string :auth_code
      t.string :transaction_id
      t.datetime :placed_at
      t.datetime :finalized_on

      t.timestamps
    end
    add_index :orders, :status
  end
end
