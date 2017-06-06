class RemoveColumnsFromEventItemEventAndOrder < ActiveRecord::Migration[5.0]
  def change
    remove_column :event_items, :flat_rate, :boolean
    remove_column :event_items, :min_freq, :integer
    remove_column :orders, :start_date, :datetime
    remove_column :orders, :end_date, :datetime
  end
end
