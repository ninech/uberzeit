class AddBilledToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :billed, :boolean, default: false, null: false
  end
end
