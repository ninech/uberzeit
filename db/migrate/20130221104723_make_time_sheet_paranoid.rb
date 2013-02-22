class MakeTimeSheetParanoid < ActiveRecord::Migration
  def up
    add_column :time_sheets, :deleted_at, :time
  end

  def down
    remove_column :time_sheets, :deleted_at
  end
end
