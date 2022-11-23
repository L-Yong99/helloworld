class AddCountryToPlaces < ActiveRecord::Migration[7.0]
  def change
    add_column :places, :country, :string
  end
end
