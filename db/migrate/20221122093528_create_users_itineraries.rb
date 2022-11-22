class CreateUsersItineraries < ActiveRecord::Migration[7.0]
  def change
    create_table :users_itineraries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :itinerary, null: false, foreign_key: true
      t.text :comment
      t.string :status

      t.timestamps
    end
  end
end
