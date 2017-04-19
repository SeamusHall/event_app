class AddDeletedAtToTables < ActiveRecord::Migration[5.0]
  def change
    add_column :event_items, :deleted_at, :datetime
    add_column :events, :deleted_at, :datetime
    add_column :orders, :deleted_at, :datetime
    add_column :roles, :deleted_at, :datetime
    add_column :user_roles, :deleted_at, :datetime
    add_column :users, :deleted_at, :datetime

    add_index :event_items, :deleted_at
    add_index :events, :deleted_at
    add_index :orders, :deleted_at
    add_index :roles, :deleted_at
    add_index :user_roles, :deleted_at
    add_index :users, :deleted_at
  end
end
