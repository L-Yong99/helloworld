class AddImageToPlaces < ActiveRecord::Migration[7.0]
  def change
    add_column :places, :image, :string, null: true
  end
end
