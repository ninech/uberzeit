class CreateTimeTypes < ActiveRecord::Migration
  def change
    create_table :time_types do |t|
      t.string :name
      t.boolean :is_work, :default => 0
      t.boolean :is_vacation, :default => 0
      t.boolean :is_onduty, :default => 0

      t.timestamps
    end
  end
end
