class RenameUidToEmail < ActiveRecord::Migration
  def change
    rename_column :users, :uid, :email
  end
end
