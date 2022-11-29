class AddStatusToActivities < ActiveRecord::Migration[7.0]
  def change
    add_column :activities, :status, :string
  end
end
