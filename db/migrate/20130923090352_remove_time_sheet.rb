class RemoveTimeSheet < ActiveRecord::Migration
  class TimeSheet < ActiveRecord::Base
    belongs_to :user
  end

  def up
    tables = %w[absences adjustments time_entries]
    models = [Absence, Adjustment, TimeEntry]

    tables.each do |table|
      say_with_time "Adding user_id to #{table}" do
        add_column table, :user_id, :integer
        add_index table, :user_id
      end
    end

    models.each do |model|
      model.all.each do |entry|
        entry.update_attribute :user, TimeSheet.find(entry.time_sheet_id).user
      end
    end

    tables.each do |table|
      say_with_time "Removing TimeSheet from #{table}" do
        remove_column table, :time_sheet_id
      end
    end

    drop_table :time_sheets

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
