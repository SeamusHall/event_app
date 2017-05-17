class TableUpgrade < ActiveRecord::Migration[5.0]
  def change
    # Add status and published to products
    add_column :products, :status, :string
    add_column :products, :published, :boolean
    add_column :products, :attachments, :string
    add_column :products, :check_status, :string
    add_column :products, :page_body, :text

    # Add Attachment to Events
    add_column :events, :attachment, :string

    # For paranoia gem
    add_column :products, :deleted_at, :datetime
    add_column :order_products, :deleted_at, :datetime
    add_column :order_product_items, :deleted_at, :datetime

    add_index :products, :deleted_at
    add_index :order_products, :deleted_at
    add_index :order_product_items, :deleted_at
  end
end
