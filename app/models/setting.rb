class Setting < ActiveRecord::Base
  attr_accessible :key, :value

  validates_presence_of :key, :value
  validates_uniqueness_of :key


  def self.work_per_day_hours
    Setting.find_by_key!(:work_per_day_hours).value.to_f
  end

  def self.work_per_day_hours=(value)
    setting = Setting.find_by_key(:work_per_day_hours)
    if setting
      setting.update_attributes!(value: value)
    else
      Setting.create!(key: :work_per_day_hours, value: value)
    end
  end

  def self.vacation_per_year_days
    Setting.find_by_key!(:vacation_per_year_days).value.to_f
  end

  def self.vacation_per_year_days=(value)
    setting = Setting.find_by_key(:vacation_per_year_days)
    if setting
      setting.update_attributes!(value: value)
    else
      Setting.create!(key: :vacation_per_year_days, value: value)
    end
  end
end
