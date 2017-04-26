class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.float :price
      t.string :image
      t.text :description
      t.boolean :sold_out

      t.timestamps
    end
  end
end