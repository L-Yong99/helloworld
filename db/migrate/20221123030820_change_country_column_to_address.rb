class ChangeCountryColumnToAddress < ActiveRecord::Migration[7.0]
  def change
    rename_column :itineraries, :country, :address
  end
end
