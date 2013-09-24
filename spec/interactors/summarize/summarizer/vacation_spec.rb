require 'spec_helper'

describe Summarize::Summarizer::Vacation do

  let(:user) { FactoryGirl.create(:user) }
  let(:range) { '2013-04-01'.to_date..'2013-04-30'.to_date }

  it 'summarizes a users\' absences by the given range' do
    FactoryGirl.create(:absence, start_date: '2013-01-07', end_date: '2013-01-07', time_type: :vacation, user: user)
    FactoryGirl.create(:absence, start_date: '2013-04-24', end_date: '2013-04-25', time_type: :vacation, user: user)

    summarizer = Summarize::Summarizer::Vacation.new(user, range)
    summarizer.summary[:redeemed].should eq(2.work_days)
    summarizer.summary[:remaining].should eq((25-2-1).work_days) # remaining after given range
  end

  it 'has summary attributes for each absence Time Type' do
    summarizer = Summarize::Summarizer::Vacation.new(user, range)
    summarizer.summary.keys.should =~ Summarize::Summarizer::Vacation::SUMMARIZE_ATTRIBUTES
  end
end
