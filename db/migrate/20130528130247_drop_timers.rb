class DropTimers < ActiveRecord::Migration

  class Timer < ActiveRecord::Base
  end

  def up
    ActiveRecord::Base.transaction do
      Timer.all.each do |timer|
        time_entry = TimeEntry.new
        time_entry.time_sheet_id = timer.time_sheet_id
        time_entry.time_type_id = timer.time_type_id
        time_entry.starts = timer.start_time
        time_entry.save!
      end

      drop_table :timers
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
