class CreateEmployments < ActiveRecord::Migration
  def change
    create_table :employments do |t|
      t.references :user
      t.datetime :start_time
      t.datetime :end_time
      t.float :workload

      t.timestamps
    end
    add_index :employments, :user_id
  end
end
