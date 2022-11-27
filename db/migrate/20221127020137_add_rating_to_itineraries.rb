class AddRatingToItineraries < ActiveRecord::Migration[7.0]
  def change
    add_column :itineraries, :rating, :integer
  end
end
