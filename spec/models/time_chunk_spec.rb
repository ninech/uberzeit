require 'spec_helper'

describe TimeChunk do

  describe '#whole_day?' do
    it 'returns true if the entry is a whole day' do
      entry = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: true, second_half_day: true)
      TimeChunk.new(parent: entry).whole_day?.should be_true
    end

    it 'returns false if the absence is not a whole day' do
      entry_first_half_day = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: true, second_half_day: false)
      entry_second_half_day = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: false, second_half_day: true)
      entry_no_flags = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: false, second_half_day: false)

      TimeChunk.new(parent: entry_first_half_day).whole_day?.should be_false
      TimeChunk.new(parent: entry_second_half_day).whole_day?.should be_false
      TimeChunk.new(parent: entry_no_flags).whole_day?.should be_true
    end
  end

  describe '#duration' do
    it 'returns the duration' do
      TimeChunk.new(range: '2013-03-06'.to_date..'2013-03-06'.to_date).duration.should eq(24.hours)
    end
  end

end
