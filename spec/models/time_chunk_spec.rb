require 'spec_helper'

describe TimeChunk do

  describe '#whole_day?' do
    it 'returns true if the entry is a whole day' do
      entry = FactoryGirl.create(:date_entry, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: true, second_half_day: true)
      TimeChunk.new(parent: entry).whole_day?.should be_true
    end

    it 'returns false if the date_entry is not a whole day' do
      entry_first_half_day = FactoryGirl.create(:date_entry, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: true, second_half_day: false)
      entry_second_half_day = FactoryGirl.create(:date_entry, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: false, second_half_day: true)
      entry_no_flags = FactoryGirl.create(:date_entry, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: false, second_half_day: false)

      TimeChunk.new(parent: entry_first_half_day).whole_day?.should be_false
      TimeChunk.new(parent: entry_second_half_day).whole_day?.should be_false
      TimeChunk.new(parent: entry_no_flags).whole_day?.should be_true
    end
  end

  describe '#duration' do
    context 'for time type which has to calculate work hours only' do
      let(:time_type) do
        mock.tap { |m| m.should_receive(:calculate_work_hours_only?).and_return(true) }
      end

      it 'calculates only the work hours' do
        TimeChunk.new(range: '2013-03-06'.to_date...'2013-03-07'.to_date, time_type: time_type).duration.should eq(UberZeit::Config[:work_per_day])
      end

      it 'calculates the work hours relative to the duration' do
        TimeChunk.new(range: '2013-03-05'.to_date..'2013-03-07'.to_date, time_type: time_type).duration.should eq(3*UberZeit::Config[:work_per_day])
      end
    end

    context 'for time type which has to calculate the whole day' do
      let(:time_type) do
        mock.tap { |m| m.should_receive(:calculate_work_hours_only?).and_return(false) }
      end

      it 'calculates only the work hours' do
        TimeChunk.new(range: '2013-03-06 00:00:00'.to_time..'2013-03-06 23:00:00'.to_time, time_type: time_type).duration.should eq(23.hours)
      end
    end
  end

end
