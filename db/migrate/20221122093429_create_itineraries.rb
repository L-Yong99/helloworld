class CreateItineraries < ActiveRecord::Migration[7.0]
  def change
    create_table :itineraries do |t|
      t.string :title
      t.date :start_date
      t.date :end_date
      t.integer :travel_days
      t.string :phase
      t.string :country, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
