class MakeTeamParanoid < ActiveRecord::Migration
  def up
    add_column :teams, :deleted_at, :time
  end

  def down
    remove_column :teams, :deleted_at
  end
end
