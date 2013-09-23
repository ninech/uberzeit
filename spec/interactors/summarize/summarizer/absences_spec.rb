require 'spec_helper'

describe Summarize::Summarizer::Absences do

  let(:user) { FactoryGirl.create(:user) }
  let(:range) { '2013-01-01'.to_date..'2013-12-31'.to_date }
  let(:summarizer) { Summarize::Summarizer::Absences.new(user, range) }

  it 'sums up each absence time type' do
    FactoryGirl.create(:absence, start_date: '2013-04-24', end_date: '2013-04-25', time_type: :vacation, user: user)

    summarizer.summary[TEST_TIME_TYPES[:vacation]].should eq(2.work_days)
  end

  it 'has summary attributes for each absence Time Type' do
    summarizer.summary.keys.should =~ TimeType.absence
  end

  describe 'with adjustments' do
    context 'adjustment is not for vacation' do
      let!(:adjustment) { FactoryGirl.create(:adjustment, user: user, time_type: TEST_TIME_TYPES[:paid_absence], duration: 3.5.work_days, date: range.min) }

      it 'adds adjustments to the total' do
        summarizer.summary[TEST_TIME_TYPES[:paid_absence]].should eq(3.5.work_days)
      end
    end

    context 'adjustment is for vacation' do
      let!(:adjustment) { FactoryGirl.create(:adjustment, user: user, time_type: TEST_TIME_TYPES[:vacation], duration: 1.work_days, date: range.min) }

      it 'does not adjustments to the total' do
        summarizer.summary[TEST_TIME_TYPES[:paid_absence]].should eq(0)
      end
    end
  end
end
