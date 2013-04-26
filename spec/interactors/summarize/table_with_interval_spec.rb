require 'spec_helper'

describe Summarize::Table do

  let(:user) { FactoryGirl.create(:user) }
  let(:another_user) { FactoryGirl.create(:user) }

  let(:summarizer_instance) do
    mock.tap do |m|
      m.stub(:summary).and_return({attribute1: 100, attribute2: 50})
    end
  end

  let(:summarizer) do
    mock.tap do |m|
      m.stub(:new).and_return(summarizer_instance)
    end
  end

  it 'creates a summary for a list of users and a specified interval' do
    range = Date.current..Date.current.next_week
    table = Summarize::TableWithInterval.new(summarizer, [user], range, 1.day)

    range, user_summaries = table.entries.first
    range.should eq(Date.current..Date.current)

    _, summary = user_summaries.first
    summary[:attribute1].should eq(100)
    summary[:attribute2].should eq(50)
  end

  it 'returns the total for a given summary attribute' do
    range = Date.current..Date.current.next_week
    table = Summarize::TableWithInterval.new(summarizer, [user, another_user], range, 1.day)

    table.total(:attribute1).should eq(range.duration.to_days * 100 * 2)
  end

end
