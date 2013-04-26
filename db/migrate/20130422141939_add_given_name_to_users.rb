class AddGivenNameToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
        t.string :given_name
    end
  end
end
