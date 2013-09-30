class RemoveRottenCarcass < ActiveRecord::Migration
  def up
    User.only_deleted.each do |user|
      user.absences.destroy_all
      user.adjustments.destroy_all
      user.time_entries.destroy_all
      user.activities.destroy_all
      user.employments.destroy_all
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
