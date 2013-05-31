class AddBirthdayToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.date :birthday
    end
  end
end
