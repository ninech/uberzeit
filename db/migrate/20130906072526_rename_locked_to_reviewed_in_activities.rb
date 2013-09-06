class RenameLockedToReviewedInActivities < ActiveRecord::Migration
  def up
    rename_column :activities, :locked, :reviewed
  end

  def down
    rename_column :activities, :reviewed, :locked
  end
end
