# == Schema Information
#
# Table name: adjustments
#
#  id           :integer          not null, primary key
#  time_type_id :integer
#  date         :date
#  duration     :integer
#  label        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  deleted_at   :datetime
#  user_id      :integer
#

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
      FactoryGirl.build(:adjustment, user: nil).should_not be_valid
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

  context 'denormalization' do
    subject { FactoryGirl.build(:adjustment, date: '2013-01-01') }

    it 'creates a TimeSpan if it does not exist yet' do
      expect { subject.save! }.to change(TimeSpan, :count)
    end

    it 'fills all the fields of TimeSpan' do
      subject.save!
      subject.time_span.duration.should eq(subject.duration)
      subject.time_span.date.should eq(subject.date)
      subject.time_span.user.should eq(subject.user)
      subject.time_span.time_type.should eq(subject.time_type)
    end

    it 'does not create multiple TimeSpans' do
      subject.save!
      subject.duration += 10
      expect { subject.save! }.to_not change(TimeSpan, :count)
    end

    it 'updates the TimeSpan' do
      subject.save!
      subject.duration += 10
      expect { subject.save! }.to change(subject.time_span, :duration)
    end

    it 'removes the TimeSpan when it gets destroyed' do
      subject.save!
      expect { subject.destroy }.to change(TimeSpan, :count)
    end
  end
end
