require 'spec_helper'

describe Adjustment do

  it 'has a valid factory' do
    FactoryGirl.create(:adjustment).should be_valid
  end

  it 'acts as paranoid' do
    adjustment = FactoryGirl.create(:adjustment)
    adjustment.destroy
    expect { Adjustment.find(adjustment.id) }.to raise_error
    expect { Adjustment.with_deleted.find(adjustment.id) }.to_not raise_error
  end

  it 'accepts a HH:MM duration' do
    adjustment = FactoryGirl.build(:adjustment, duration_in_hours: '4:30')
    adjustment.duration.should eq(4.5.hours)
  end

  it 'returns the duration as HH:MM' do
    adjustment = FactoryGirl.build(:adjustment, duration_in_hours: '4:30')
    adjustment.duration_in_hours.should eq('04:30')
  end

  describe 'validations' do
    it 'requires a time sheet' do
      FactoryGirl.build(:adjustment, time_sheet: nil).should_not be_valid
    end

    it 'requires a time type' do
      FactoryGirl.build(:adjustment, time_type: nil).should_not be_valid
    end

    it 'requires a date' do
      FactoryGirl.build(:adjustment, date: nil).should_not be_valid
    end

    it 'requires a duration' do
      FactoryGirl.build(:adjustment, duration: nil).should_not be_valid
    end

    it 'makes sure duration is an integer' do
      FactoryGirl.build(:adjustment, duration: '123c').should_not be_valid
    end

    it 'makes sure date is a valid date' do
      FactoryGirl.build(:adjustment, date: '2013-13-01').should_not be_valid
    end
  end
end
