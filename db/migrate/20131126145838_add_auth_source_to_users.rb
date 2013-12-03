class AddAuthSourceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :auth_source, :string, default: nil, null: true
  end
end
