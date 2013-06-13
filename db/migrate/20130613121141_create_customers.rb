class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers, { id: false } do |t|
      t.integer :id
      t.string :name

      t.timestamps
    end

    add_index :customers, :id, unique: true
  end
end
