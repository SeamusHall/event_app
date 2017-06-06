class Removecolumnsfromevents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :starts_on, :datetime
    remove_column :events, :ends_on, :datetime
  end
end
