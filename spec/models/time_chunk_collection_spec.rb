require 'spec_helper'

describe TimeChunkCollection do

  let(:object_to_scan) { mock }
  let(:time_chunk_finder) do
    mock.tap do |m|
      m.should_receive(:chunks).and_return(time_chunks)
    end
  end

  let(:date) { '2013-03-06'.to_date }
  let(:range) { date...('2013-03-13'.to_date) }
  let(:time_type_scope) { :work }
  let(:time_chunks) { [] }

  before { TimeChunkFinder.stub(:new).and_return(time_chunk_finder) }

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
      let(:collection) { TimeChunkCollection.new(range, object_to_scan) }

      it 'returns the total of the chunks' do
        collection.total.should eq(9.5.hours)
      end

      it 'returns the total of the given type' do
        collection.total(:work).should eq(9.hours)
        collection.total(:break).should eq(0.5.hours)
        collection.total(:break, :work).should eq(9.5.hours)
      end

      context 'vacation' do
        let(:time_chunks) do
          [
            TimeChunk.new(starts: '2013-03-06'.to_date, ends: '2013-03-06'.to_date, first_half_day: true, second_half_day: true, time_type: time_type_vacation),
            TimeChunk.new(starts: '2013-03-07'.to_date, ends: '2013-03-07'.to_date, first_half_day: true, second_half_day: true, time_type: time_type_vacation)
          ]
        end
        it 'takes into account whether the whole day should be treated as a work day' do
          collection.total(:vacation).should eq(2.work_days)
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

end
