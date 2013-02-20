class CreateTimeTypes < ActiveRecord::Migration
  def change
    create_table :time_types do |t|
      t.string :name
      t.boolean :is_work, :default => :false
      t.boolean :is_vacation, :default => :false
      t.boolean :is_onduty, :default => :false

      t.timestamps
    end
  end
end
