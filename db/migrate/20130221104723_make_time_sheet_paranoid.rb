class MakeTimeSheetParanoid < ActiveRecord::Migration
  def up
    add_column :time_sheets, :deleted_at, :datetime
  end

  def down
    remove_column :time_sheets, :deleted_at
  end
end
