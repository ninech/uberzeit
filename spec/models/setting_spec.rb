require 'spec_helper'

describe Setting do

  describe '::work_per_day_hours' do
    it 'returns the value from the database' do
      Setting.where(key: :work_per_day_hours).first.update_attributes(value: 1)
      expect(Setting.work_per_day_hours).to eq(1)
    end
  end

  describe '::work_per_day_hours=' do
    it 'persists the value' do
      expect { Setting.work_per_day_hours = 12 }.to change(Setting, :work_per_day_hours)
    end
  end

  describe '::vacation_per_year_days' do
    it 'returns the value from the database' do
      Setting.where(key: :vacation_per_year_days).first.update_attributes(value: 12)
      expect(Setting.vacation_per_year_days).to eq(12)
    end
  end

  describe '::vacation_per_year_days=' do
    it 'persists the value' do
      expect { Setting.vacation_per_year_days = 12 }.to change(Setting, :vacation_per_year_days)
    end
  end

end
