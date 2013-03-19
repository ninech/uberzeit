require 'spec_helper'

describe TimeChunkCollection do
  let(:time_chunks) { [] }

  context 'no chunks' do
    it 'returns zero' do
      collection = TimeChunkCollection.new(time_chunks)
      collection.total.should eq(0.0)
    end
  end

  context 'with chunks' do
    let(:time_type_work) { TEST_TIME_TYPES[:work] }
    let(:time_type_break) { TEST_TIME_TYPES[:break] }
    let(:time_type_vacation) { TEST_TIME_TYPES[:vacation] }
    let(:time_chunks) do
      [
        TimeChunk.new(starts: '2013-03-07 09:00:00'.to_time, ends: '2013-03-07 12:00:00'.to_time, time_type: time_type_work),
        TimeChunk.new(starts: '2013-03-07 12:00:00'.to_time, ends: '2013-03-07 12:30:00'.to_time, time_type: time_type_break),
        TimeChunk.new(starts: '2013-03-07 12:30:00'.to_time, ends: '2013-03-07 18:30:00'.to_time, time_type: time_type_work)
      ]
    end
    let(:collection) { TimeChunkCollection.new(time_chunks) }

    describe '#total' do
      it 'returns the total of the chunks' do
        collection.total.should eq(9.5.hours)
      end

      it 'returns the total of the given type' do
        collection.total(:work).should eq(9.hours)
        collection.total(:break).should eq(0.5.hours)
        collection.total(:break, :work).should eq(9.5.hours)
      end
    end

    describe '#total_for_flag' do
      it 'returns the total of the chunks for the given flag' do
        collection.total_for_flag(:treat_as_working_time?).should eq(9.hours)
      end
    end

    describe '#length' do
      it 'returns the count of the chunks' do
        collection.length.should eq(3)
      end
    end

    describe '#each' do
      it 'allows you to iterate over the chunks' do
        a = []
        collection.each do |chunk|
          a << chunk.time_type.name
        end
        a.should eq(%w{test_work test_break test_work})
      end
    end

    describe '#map' do
      it 'allows you to map over the chunks' do
        collection.map { |chunk| chunk.time_type.name }.should eq(%w{test_work test_break test_work})
      end
    end

    describe '#empty?' do
      it 'allows you to check whether there are chunks' do
        collection.empty?.should be_false
      end
    end
  end
end
