class AddCustomerNumber < ActiveRecord::Migration
  def up
    rename_column :customers, :id, :number
    add_column :customers, :id, :primary_key
  end

  def down
    remove_column :customers, :id
    rename_column :customers, :number, :id
  end
end
