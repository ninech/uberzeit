require 'spec_helper'

describe TimeChunkCollection do

  let(:object_to_scan) do
    mock.tap do |m|
      m.should_receive(:find_chunks).with(date_or_range.to_range, time_type_scope).and_return(time_chunks)
    end
  end

  let(:date) { '2013-03-06'.to_date }
  let(:range) { date...('2013-03-13'.to_date) }
  let(:time_type_scope) { :work }
  let(:time_chunks) { [] }

  describe '#new' do
    context 'date' do
      let(:date_or_range) { date }
      it 'handles a single date' do
        TimeChunkCollection.new(date, object_to_scan, time_type_scope).range.should eq(date.to_range)
      end
    end

    context 'range' do
      let(:date_or_range) { range }
      it 'handles a range' do
        TimeChunkCollection.new(range, object_to_scan, time_type_scope).range.should eq(range.to_range)
      end
    end
  end

  describe '#total' do
    let(:time_type_scope) { nil }
    let(:date_or_range) { range }

    context 'no chunks' do
      let(:date_or_range) { date }
      it 'returns zero' do
        collection = TimeChunkCollection.new(date, object_to_scan)
        collection.total.should eq(0.0)
      end
    end

    context 'with chunks' do

      let(:time_type_work) do
        mock.tap do |m|
          m.stub(:calculate_work_hours_only?).and_return(false)
          m.stub(:name).and_return('work')
        end
      end
      let(:time_type_break) do
        mock.tap do |m|
          m.stub(:calculate_work_hours_only?).and_return(false)
          m.stub(:name).and_return('break')
        end
      end

      let(:time_chunks) do
        [
          TimeChunk.new(starts: '2013-03-07 09:00:00'.to_time, ends: '2013-03-07 12:00:00'.to_time, time_type: time_type_work),
          TimeChunk.new(starts: '2013-03-07 12:00:00'.to_time, ends: '2013-03-07 12:30:00'.to_time, time_type: time_type_break),
          TimeChunk.new(starts: '2013-03-07 12:30:00'.to_time, ends: '2013-03-07 18:30:00'.to_time, time_type: time_type_work)
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
