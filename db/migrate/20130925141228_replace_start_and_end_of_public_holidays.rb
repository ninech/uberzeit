class ReplaceStartAndEndOfPublicHolidays < ActiveRecord::Migration
  def up
    rename_column :public_holidays, :start_date, :date
    remove_column :public_holidays, :end_date
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
