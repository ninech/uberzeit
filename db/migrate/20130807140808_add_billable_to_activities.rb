class AddBillableToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :billable, :boolean, default: false
  end
end
