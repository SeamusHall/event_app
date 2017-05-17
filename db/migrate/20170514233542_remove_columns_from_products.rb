class RemoveColumnsFromProducts < ActiveRecord::Migration[5.0]
  def change
    remove_column :products, :image
    remove_column :products, :sold_out
  end
end
