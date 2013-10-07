# == Schema Information
#
# Table name: time_spans
#
#  id                             :integer          not null, primary key
#  date                           :date
#  duration                       :integer
#  duration_in_work_days          :float
#  duration_bonus                 :integer
#  user_id                        :integer
#  time_type_id                   :integer
#  time_spanable_id               :integer
#  time_spanable_type             :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  credited_duration              :integer
#  credited_duration_in_work_days :float
#

require 'spec_helper'

describe TimeSpan do
  subject { TimeSpan.new }

  describe '#duration=' do
    it 'calculates duration_in_work_days' do
      expect { subject.duration = 1.5.days }.to change { subject.duration_in_work_days }
    end

    it 'calculates duration_in_work_days correctly' do
      subject.duration = 4.25.hours
      subject.duration_in_work_days.should eq(0.5)
    end
  end

  describe '#duration_in_work_days=' do
    it 'calculates duration' do
      expect { subject.duration_in_work_days = 1 }.to change { subject.duration }
    end

    it 'calculates duration correctly' do
      subject.duration_in_work_days = 1
      subject.duration.should eq(8.5.hours)
    end
  end

  describe '#credited_duration=' do
    it 'calculates credited_duration_in_work_days' do
      expect { subject.credited_duration = 1.5.work_days }.to change { subject.credited_duration_in_work_days }
    end

    it 'calculates credited_duration_in_work_days correctly' do
      subject.credited_duration = 4.25.hours
      subject.credited_duration_in_work_days.should eq(0.5)
    end
  end
  describe '#credited_duration_in_work_days=' do
    it 'calculates credited_duration' do
      expect { subject.credited_duration_in_work_days = 1 }.to change { subject.credited_duration }
    end

    it 'calculates credited_duration correctly' do
      subject.credited_duration_in_work_days = 1
      subject.credited_duration.should eq(8.5.hours)
    end
  end

  describe 'scopes' do

    let(:user) { FactoryGirl.create(:user) }
    let(:user_id) { user.id }
    let(:time_type_id) { TEST_TIME_TYPES[:vacation].id }
    let(:range) { '2013-01-01'.to_date..'2013-12-31'.to_date }

    subject do
      TimeSpan
        .date_between(range)
        .absences
        .duration_in_work_day_sum_per_user_and_time_type
    end

    it 'sums up each absence time type' do
      FactoryGirl.create(:absence, start_date: '2013-04-24', end_date: '2013-04-25', time_type: :vacation, user: user)

      subject.should eq([user_id, time_type_id] => 2)
    end

    describe 'with adjustments' do
      context 'adjustment is not for vacation' do
        let!(:adjustment) { FactoryGirl.create(:adjustment, user: user, time_type: TEST_TIME_TYPES[:paid_absence], duration: 3.5.work_days, date: range.min) }
        let(:time_type_id) { TEST_TIME_TYPES[:paid_absence].id }

        it 'adds adjustments to the total' do
          subject.should eq([user_id, time_type_id] => 3.5)
        end
      end

      context 'adjustment is for vacation' do
        let!(:adjustment) { FactoryGirl.create(:adjustment, user: user, time_type: TEST_TIME_TYPES[:vacation], duration: 1.work_days, date: range.min) }
        let(:time_type_id) { TEST_TIME_TYPES[:paid_absence].id }

        it 'does not adjustments to the total' do
          subject.should eq({})
        end
      end
    end
  end
end
