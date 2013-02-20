class CreateTimeSheets < ActiveRecord::Migration
  def change
    create_table :time_sheets do |t|
      t.references :user

      t.timestamps
    end
    add_index :time_sheets, :user_id
  end
end
