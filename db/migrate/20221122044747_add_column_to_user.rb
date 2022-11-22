class AddColumnToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :first_name, :string, null: false
    add_column :users, :last_name, :string, null: false
    add_column :users, :gender, :string, null: false
    add_column :users, :country, :string, null: false
  end
end
