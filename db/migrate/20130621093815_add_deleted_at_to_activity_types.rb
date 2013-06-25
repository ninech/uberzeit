class AddDeletedAtToActivityTypes < ActiveRecord::Migration
  def change
    add_column :activity_types, :deleted_at, :datetime
  end
end
