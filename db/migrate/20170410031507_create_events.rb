class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.text :page_body
      t.datetime :available_at
      t.datetime :unavailable_at
      t.datetime :starts_on
      t.datetime :ends_on

      t.timestamps
    end
  end
end
