class SwitchBonusFactorToBonusCalculator < ActiveRecord::Migration
  def up
    add_column :time_types, :bonus_calculator, :string

    say_with_time 'migrating old bonus factors' do
      TimeType.all.each do |time_type|
        if time_type.bonus_factor > 0
          time_type.bonus_calculator = 'nine_on_duty'
          time_type.save!
        end
      end
    end

    remove_column :time_types, :bonus_factor
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
