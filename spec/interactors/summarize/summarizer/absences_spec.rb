require 'spec_helper'

describe Summarize::Summarizer::Absences do

  let(:user) { FactoryGirl.create(:user, with_sheet: true) }
  let(:range) { '2013-01-01'.to_date..'2013-12-31'.to_date }

  it 'summarizes a users\' absences by the given range' do
    FactoryGirl.create(:absence, start_date: '2013-04-24', end_date: '2013-04-25', time_type: :vacation, time_sheet: user.current_time_sheet)

    summarizer = Summarize::Summarizer::Absences.new(user, range)
    summarizer.summary[TEST_TIME_TYPES[:vacation]].should eq(2.work_days)
  end

  it 'has summary attributes for each absence Time Type' do
    summarizer = Summarize::Summarizer::Absences.new(user, range)
    summarizer.summary.keys.should =~ TimeType.absence
  end
end
