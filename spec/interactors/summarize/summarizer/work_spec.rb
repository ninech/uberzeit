require 'spec_helper'

describe Summarize::Summarizer::Work do

  let(:user) { FactoryGirl.create(:user) }
  let(:time_sheet) { user.current_time_sheet }
  let(:range) { '2013-01-01'.to_date..'2013-12-31'.to_date }
  let(:summarizer) { Summarize::Summarizer::Work.new(user, range) }

  it 'sums up each work time type' do
    FactoryGirl.create(:time_entry, starts: '2013-04-24 9:00:00', ends: '2013-04-24 18:00:00', time_type: :work, time_sheet: user.current_time_sheet)

    summarizer.summary[:effective_worked].should eq(9.hours)
  end

  it 'has summary attributes for each value in SUMMARIZE_ATTRIBUTES' do
    summarizer.summary.keys.should =~ Summarize::Summarizer::Work::SUMMARIZE_ATTRIBUTES
  end

  describe 'adjustments' do
    context 'adjustment is for vacation' do
      let!(:adjustment) { FactoryGirl.create(:adjustment, time_sheet: time_sheet, time_type: TEST_TIME_TYPES[:vacation], duration: 1.0.work_days, date: range.min) }

      it 'excludes the adjustment for the total adjustment duration' do
        summarizer.summary[:adjustments].should eq(0)
      end
    end

    context 'adjustment is not for vacation' do
      let!(:adjustment) { FactoryGirl.create(:adjustment, time_sheet: time_sheet, time_type: TEST_TIME_TYPES[:paid_absence], duration: 1.0.work_days, date: range.min) }

      it 'includes the adjustment for the total adjustment duration' do
        summarizer.summary[:adjustments].should eq(1.0.work_days)
      end
    end
  end
end
