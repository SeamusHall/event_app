class CreateEventItem < ActiveRecord::Migration[5.0]
  def change
    create_table :event_items do |t|
      t.references :event, foreign_key: true
      t.string :description
      t.decimal :price, precision: 9, scale: 2
      t.decimal :tax, precision: 6, scale: 5
      t.integer :max_event
      t.integer :max_order
      t.integer :min_freq
      t.boolean :flat_rate, default: false

      t.timestamps
    end
  end
end
