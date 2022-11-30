class AddBookingToActivities < ActiveRecord::Migration[7.0]
  def change
    add_column :activities, :booking, :string
  end
end
