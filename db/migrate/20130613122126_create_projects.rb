class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.references :customer
      t.string :name

      t.timestamps
    end
    add_index :projects, :customer_id
  end
end
