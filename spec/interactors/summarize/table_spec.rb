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

  it 'creates a summary for a list of users' do
    range = Date.current..Date.current.next_week
    table = Summarize::Table.new(summarizer, [user], range)

    _, summary = table.entries.first
    summary[:attribute1].should eq(100)
    summary[:attribute2].should eq(50)
  end

  it 'returns the total for a given summary attribute' do
    range = Date.current..Date.current.next_week
    table = Summarize::Table.new(summarizer, [user, another_user], range)

    table.total(:attribute1).should eq(200)
  end

end
