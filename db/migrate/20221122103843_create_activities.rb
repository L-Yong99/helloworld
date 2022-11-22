class CreateActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :activities do |t|
      t.text :description
      t.references :place, null: false, foreign_key: true
      t.references :itinerary, null: false, foreign_key: true
      t.date :date
      t.integer :day
      t.time :time
      t.integer :event_sequence

      t.timestamps
    end
  end
end
