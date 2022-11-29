class AddColumnToItineraries < ActiveRecord::Migration[7.0]
  def change
    add_column :itineraries, :review, :string
    add_column :itineraries, :recommend, :string
    add_column :itineraries, :pros, :string
    add_column :itineraries, :cons, :string
  end
end
