class Setting < ActiveRecord::Base
  attr_accessible :key, :value

  validates_presence_of :key, :value
  validates_uniqueness_of :key

  VALID_SETTING_KEYS = [:work_per_day_hours, :vacation_per_year_days]

  class << self
    VALID_SETTING_KEYS.each do |key|
      define_method(key) do
        Setting.find_by_key!(key).value.to_f
      end

      define_method("#{key}=") do |value|
        setting = Setting.find_by_key(key)
        if setting
          setting.update_attributes!(value: value)
        else
          Setting.create!(key: key, value: value)
        end
      end
    end
  end
end
