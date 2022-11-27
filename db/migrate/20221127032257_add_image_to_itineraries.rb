class AddImageToItineraries < ActiveRecord::Migration[7.0]
  def change
    add_column :itineraries, :image, :string
  end
end
