class ChangeColumnDefaultToitineraries < ActiveRecord::Migration[7.0]
  def change
    change_column_default(:itineraries, :phase, 'in plan')
  end
end
