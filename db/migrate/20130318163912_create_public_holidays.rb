class CreatePublicHolidays < ActiveRecord::Migration
  def change
    create_table :public_holidays do |t|
      t.date :start_date
      t.date :end_date
      t.string :name
      t.boolean :first_half_day
      t.boolean :second_half_day

      t.timestamps
    end
  end
end
