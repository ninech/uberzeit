class CreateEmployments < ActiveRecord::Migration
  def change
    create_table :employments do |t|
      t.references :user
      t.date :start_date
      t.date :end_date
      t.float :workload, :default => 100
      t.timestamps
    end

    add_index :employments, :user_id
  end
end
