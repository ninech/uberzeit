class CreateDays < ActiveRecord::Migration
  def change
    create_table :days do |t|
      t.references :user
      t.date :date
      t.integer :planned_working_time

      t.timestamps
    end
    add_index :days, :user_id
    add_index :days, :date
  end
end
