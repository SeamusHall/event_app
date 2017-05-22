class YetMoreTableChanges < ActiveRecord::Migration[5.0]
  def change
    # use this to check if event item is paid for
    # if paid for have item disappear from event
    add_column :event_items, :check_status, :string
    add_column :orders, :terms, :boolean

    add_column :products, :quantity, :integer
    add_column :products, :max_to_sell, :integer
  end
end
