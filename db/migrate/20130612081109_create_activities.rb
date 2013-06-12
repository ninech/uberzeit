class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :activity_type
      t.references :user
      t.date :date
      t.integer :duration
      t.text :description
      t.integer :customer_id
      t.integer :project_id
      t.integer :redmine_ticket_id
      t.integer :otrs_ticket_id

      t.timestamps
    end
    add_index :activities, :activity_type_id
    add_index :activities, :user_id
    add_index :activities, :customer_id
    add_index :activities, :project_id
    add_index :activities, :redmine_ticket_id
    add_index :activities, :otrs_ticket_id
  end
end
