class MakePublicHolidaysParanoid < ActiveRecord::Migration
  def up
    add_column :public_holidays, :deleted_at, :datetime
  end

  def down
    add_column :public_holidays, :deleted_at, :datetime
  end
end

