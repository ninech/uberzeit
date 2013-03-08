require 'spec_helper'

describe TimeChunk do

  describe '#whole_day?' do
    it 'returns true if the entry is a whole day' do
      TimeChunk.new(first_half_day: true, second_half_day: true).whole_day?.should be_true
    end

    it 'returns false if the entru is not a whole day' do
      TimeChunk.new(first_half_day: true, second_half_day: false).whole_day?.should be_false
      TimeChunk.new(first_half_day: false, second_half_day: true).whole_day?.should be_false
      TimeChunk.new(first_half_day: false, second_half_day: false).whole_day?.should be_false
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
