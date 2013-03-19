require 'spec_helper'

describe FindTimeChunks do
  let(:time_entries) do
    [
      FactoryGirl.build(:time_entry, start_time: '2013-07-22 08:00:00', end_time: '2013-07-22 18:00:00', time_type: :work),
      FactoryGirl.build(:time_entry, start_time: '2013-12-31 23:00:00', end_time: '2014-01-01 12:00:00', time_type: :work)
    ]
  end

  let(:absences) do
    [
      FactoryGirl.build(:absence, start_date: '2012-12-23', end_date: '2013-01-08', time_type: :vacation),
      FactoryGirl.build(:absence, start_date: '2013-07-20', end_date: '2013-07-21', time_type: :work),
      FactoryGirl.build(:absence, start_date: '2013-07-23', end_date: '2013-07-24', time_type: :vacation)
    ]
  end

  let(:time_entry_relation) do
    mock.tap do |m|
      m.stub(:entries_in_range).and_return(time_entries)
    end
  end

  let(:absence_relation) do
    mock.tap do |m|
      m.stub(:entries_in_range).and_return(absences)
    end
  end

  let(:all_relations) { [time_entry_relation, absence_relation] }

  it 'handles single and mulitple entry relations' do
    find_chunks = FindTimeChunks.new(time_entry_relation)
    find_chunks.in_year(2013).should_not be_empty

    find_chunks = FindTimeChunks.new(all_relations)
    find_chunks.in_year(2013).should_not be_empty
  end

  it 'sets the duration relative to the daily working time for chunks whose range is half or whole day' do
    relation = mock.tap do |m|
      m.stub(:entries_in_range).and_return([
                                            FactoryGirl.build(:absence, start_date: '2013-07-20', end_date: '2013-07-20', time_type: :work),
                                            FactoryGirl.build(:absence, start_date: '2013-07-21', end_date: '2013-07-21', first_half_day: true, time_type: :work)])
    end
    find_chunks = FindTimeChunks.new(relation)
    found_chunks = find_chunks.in_day('2013-07-20'.to_date)
    found_chunks.chunks.first.duration.should eq(8.5.hours)

    found_chunks = find_chunks.in_day('2013-07-21'.to_date)
    found_chunks.chunks.first.duration.should eq(4.25.hours)
  end

  context '#in_year' do
    let(:find_chunks) { FindTimeChunks.new(all_relations) }
    let(:found_chunks) { find_chunks.in_year(2013) }
    let(:range_starts) { Time.zone.local(2013) }
    let(:range_ends) { Time.zone.local(2014) }

    it 'returns a TimeChunkCollection' do
      found_chunks.should be_kind_of(TimeChunkCollection)
    end

    it 'finds chunks in a year' do
      found_chunks.should_not be_empty
    end

    it 'clips the chunks to the specified range' do
      found_chunks.each do |chunk|
        chunk.starts.should be >= range_starts
        chunk.ends.should be <= range_ends
      end
    end
  end

  context '#in_range' do
    let(:find_chunks) { FindTimeChunks.new(all_relations) }
    let(:range_starts) { '2013-07-21'.to_date }
    let(:range_ends) { '2013-07-22'.to_date }
    let(:found_chunks) { find_chunks.in_range(range_starts..range_ends) }

    it 'returns a TimeChunkCollection' do
      found_chunks.should be_kind_of(TimeChunkCollection)
    end

    it 'finds chunks in a year' do
      found_chunks.should_not be_empty
    end

    it 'clips the chunks to the specified range' do
      found_chunks.each do |chunk|
        chunk.starts.should be >= range_starts.to_time
        chunk.ends.should be <= range_ends.to_time + 1.day # end date is inclusive
      end
    end
  end

  context '#in_day' do
    let(:find_chunks) { FindTimeChunks.new(all_relations) }
    let(:day) { '2013-07-21'.to_date }
    let(:found_chunks) { find_chunks.in_day(day) }

    it 'returns a TimeChunkCollection' do
      found_chunks.should be_kind_of(TimeChunkCollection)
    end

    it 'finds chunks in a year' do
      found_chunks.should_not be_empty
    end

    it 'clips the chunks to the specified range' do
      found_chunks.each do |chunk|
        chunk.starts.should be >= day.to_time
        chunk.ends.should be <= day.to_time + 1.day
      end
    end
  end
end
