class CreateAdjustments < ActiveRecord::Migration
  def change
    create_table :adjustments do |t|
      t.references :time_sheet
      t.references :time_type
      t.date :date
      t.integer :duration
      t.string :label

      t.timestamps
    end
    add_index :adjustments, :time_sheet_id
    add_index :adjustments, :time_type_id
  end
end
