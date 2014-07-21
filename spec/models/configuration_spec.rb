require 'spec_helper'

describe ::Configuration do
  describe 'dynamic getters and setters' do
    Setting::VALID_SETTING_KEYS.each do |key|
      describe "for #{key}" do
        it 'correctly remembers a set value' do
          subject.send("#{key}=", 69)
          expect(subject.send(key)).to eq(69)
        end

        it 'asks Setting for values it doesn\'t yet know' do
          expect(Setting).to receive(key)
          subject.send(key)
        end

        it 'does not update the setting before save is called' do
          expect(Setting).to_not receive("#{key}=")
          subject.send("#{key}=", 69)
        end

        it 'updates the setting when save is called' do
          subject.send("#{key}=", 69)
          expect(Setting).to receive("#{key}=")
          subject.save
        end
      end
    end
  end

  describe 'validation' do
    it 'does not accept negative work_per_day_hours' do
      subject.work_per_day_hours = -1
      expect(subject).to_not be_valid
    end

    it 'does not accept negative vacation_per_year_days' do
      subject.vacation_per_year_days = -1
      expect(subject).to_not be_valid
    end

    it 'accepts valid values' do
      subject.work_per_day_hours = 10
      subject.vacation_per_year_days = 99.5
      expect(subject).to be_valid
    end
  end

  describe 'callback' do
    it 'flushes the cache if work_per_day_hours changed' do
      expect(Day).to receive(:delete_all)
      subject.work_per_day_hours = 10
      subject.save
    end
  end
end
