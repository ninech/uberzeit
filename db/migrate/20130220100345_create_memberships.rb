class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :team
      t.references :user
      t.string :role

      t.timestamps
    end
    add_index :memberships, :team_id
    add_index :memberships, :user_id

    # enforce uniqueness of team-user-role relationship
    add_index(:memberships, [:team_id, :user_id, :role], :unique => true) 
  end
end
