require 'spec_helper'

describe TimeChunkCollection do
  let(:time_type_work) { TEST_TIME_TYPES[:work] }
  let(:time_type_break) { TEST_TIME_TYPES[:break] }
  let(:time_type_vacation) { TEST_TIME_TYPES[:vacation] }
  let(:time_type_onduty) { TEST_TIME_TYPES[:onduty] }

  let(:time_chunks) { [] }
  let(:collection) { TimeChunkCollection.new(time_chunks) }

  context 'no chunks' do
    it 'returns zero' do
      collection = TimeChunkCollection.new(time_chunks)
      collection.total.should eq(0.0)
    end
  end

  context 'with chunks' do
    let(:time_chunks) do
      [
        TimeChunk.new(starts: '2013-03-07 09:00:00'.to_time, ends: '2013-03-07 12:00:00'.to_time, time_type: time_type_work),
        TimeChunk.new(starts: '2013-03-07 12:30:00'.to_time, ends: '2013-03-07 18:30:00'.to_time, time_type: time_type_work),
        TimeChunk.new(starts: '2013-03-07 20:00:00'.to_time, ends: '2013-03-07 20:30:00'.to_time, time_type: time_type_onduty),
        TimeChunk.new(starts: '2013-03-07 21:00:00'.to_time, ends: '2013-03-07 22:00:00'.to_time, time_type: time_type_break)
      ]
    end

    describe '#total' do
      it 'returns the total of the chunks' do
        collection.total.should eq(9.5.hours)
      end

      it 'uses the factor in the time type of every chunk' do
        time_type_onduty.should_receive(:calculation_factor).and_return(2.0)
        collection.total.should eq(10.0.hours)
      end
    end

    describe '#length' do
      it 'returns the count of the chunks' do
        collection.length.should eq(4)
      end
    end

    describe '#each' do
      it 'allows you to iterate over the chunks' do
        a = []
        collection.each do |chunk|
          a << chunk.time_type.name
        end
        a.should eq(%w{test_work test_work test_onduty test_break})
      end
    end

    describe '#map' do
      it 'allows you to map over the chunks' do
        collection.map { |chunk| chunk.time_type.name }.should eq(%w{test_work test_work test_onduty test_break})
      end
    end

    describe '#empty?' do
      it 'allows you to check whether there are chunks' do
        collection.empty?.should be_false
      end
    end
  end

  context 'overlapping absences' do
    describe '#total' do
      let(:user) { FactoryGirl.create(:user) }
      let(:time_sheet) { user.time_sheets.first }
      let(:absence1) { FactoryGirl.build(:absence, time_type: time_type_vacation, start_date: '2013-03-07', end_date: '2013-03-08') }
      let(:absence2) { FactoryGirl.build(:absence, time_type: time_type_vacation, start_date: '2013-03-07', end_date: '2013-03-07', first_half_day: true) }
      let(:time_chunks) do
        [
          TimeChunk.new(starts: '2013-03-07'.to_date.midnight, ends: '2013-03-08'.to_date.midnight, time_type: time_type_vacation, parent: absence1),
          TimeChunk.new(starts: '2013-03-08'.to_date.midnight, ends: '2013-03-09'.to_date.midnight, time_type: time_type_vacation, parent: absence1),
          TimeChunk.new(starts: '2013-03-07'.to_date.midnight, ends: '2013-03-08'.to_date.midnight, time_type: time_type_vacation, parent: absence2),
        ]
      end

      it 'counts overlapping absences as one absence' do
        collection.total.should eq(17.0.hours)
      end
    end
  end
end
