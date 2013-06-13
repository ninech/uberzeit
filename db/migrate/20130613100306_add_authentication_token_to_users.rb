class AddAuthenticationTokenToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string :authentication_token
    end

    say_with_time "Add authentication token to existing users" do
      User.with_deleted.all.each do |user|
        user.ensure_authentication_token
        user.save!
      end
    end

    add_index :users, :authentication_token, :unique => true
  end

  def down
    remove_index :users, :authentication_token
    remove_column :users, :authentication_token
  end
end
