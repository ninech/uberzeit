require 'spec_helper'

describe TimeChunkCollection do

  let(:object_to_scan) do
    mock.tap do |m|
      m.should_receive(:find_chunks).and_return(time_chunks)
    end
  end

  let(:date) { '2013-03-06'.to_date }
  let(:range) { date...('2013-03-13'.to_date) }
  let(:time_chunks) { [] }

  describe '#new' do
    it 'handles a single date' do
      TimeChunkCollection.new(date, object_to_scan).range.should eq(date.to_range)
    end

    it 'handles a range' do
      TimeChunkCollection.new(range, object_to_scan).range.should eq(range.to_range)
    end
  end

  describe '#total' do

    context 'no chunks' do
      it 'returns zero' do
        collection = TimeChunkCollection.new(date, object_to_scan)
        collection.total.should eq(0.0)
      end
    end

    context 'with chunks' do

      let(:time_chunks) do
        [
          TimeChunk.new(starts: '2013-03-07 09:00:00'.to_time, ends: '2013-03-07 12:00:00'.to_time, time_type: :work),
          TimeChunk.new(starts: '2013-03-07 12:00:00'.to_time, ends: '2013-03-07 12:30:00'.to_time, time_type: :break),
          TimeChunk.new(starts: '2013-03-07 12:30:00'.to_time, ends: '2013-03-07 18:30:00'.to_time, time_type: :work)
        ]
      end

      let(:collection) { TimeChunkCollection.new(range, object_to_scan) }
      it 'returns the total of the chunks' do
        collection.total.should eq(9.5.hours)
      end

      it 'returns the total of the given type' do
        collection.total(:work).should eq(9.hours)
        collection.total(:break).should eq(0.5.hours)
        collection.total(:break, :work).should eq(9.5.hours)
      end
    end

  end

end
