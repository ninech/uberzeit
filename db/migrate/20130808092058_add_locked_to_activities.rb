class AddLockedToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :locked, :boolean, default: false, null: false
  end
end
