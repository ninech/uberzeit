require 'spec_helper'

describe Summarize::Summarizer::Work do

  let(:user) { FactoryGirl.create(:user, with_sheet: true) }
  let(:range) { '2013-01-01'.to_date..'2013-12-31'.to_date }

  it 'summarizes a users\' time by the given range' do
    FactoryGirl.create(:time_entry, starts: '2013-04-24 9:00:00', ends: '2013-04-24 18:00:00', time_type: :work, time_sheet: user.current_time_sheet)

    summarizer = Summarize::Summarizer::Work.new(user, range)
    summarizer.summary[:effective_worked].should eq(9.hours)
  end

  it 'has summary attributes for each value in SUMMARIZE_ATTRIBUTES' do
    summarizer = Summarize::Summarizer::Work.new(user, range)
    summarizer.summary.keys.should =~ Summarize::Summarizer::Work::SUMMARIZE_ATTRIBUTES
  end
end
