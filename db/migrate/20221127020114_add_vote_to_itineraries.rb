class AddVoteToItineraries < ActiveRecord::Migration[7.0]
  def change
    add_column :itineraries, :vote, :integer
  end
end
