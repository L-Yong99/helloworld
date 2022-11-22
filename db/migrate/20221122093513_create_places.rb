class CreatePlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :places do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.text :review_summary
      t.string :category, null: false
      t.integer :rating, null: false
      t.boolean :booking, null: false
      t.float :lat, null: false
      t.float :lng, null: false

      t.timestamps
    end
  end
end
