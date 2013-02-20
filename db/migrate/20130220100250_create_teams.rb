class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.string :ldap_id

      t.timestamps
    end
  end
end
