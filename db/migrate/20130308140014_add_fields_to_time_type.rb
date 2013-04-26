class AddFieldsToTimeType < ActiveRecord::Migration
  def change
    remove_column :time_types, :is_onduty

    add_column :time_types, :treat_as_work, :boolean, default: false
    add_column :time_types, :daywise, :boolean
    add_column :time_types, :timewise, :boolean
  end
end
