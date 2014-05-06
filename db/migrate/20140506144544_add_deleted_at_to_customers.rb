class AddDeletedAtToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :deleted_at, :datetime
  end
end
