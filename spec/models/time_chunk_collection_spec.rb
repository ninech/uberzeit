require 'spec_helper'

describe TimeChunkCollection do
  let(:time_type_work) { TEST_TIME_TYPES[:work] }
  let(:time_type_compensation) { TEST_TIME_TYPES[:compensation] }
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
        TimeChunk.new(starts: '2013-03-07 21:00:00'.to_time, ends: '2013-03-07 22:00:00'.to_time, time_type: time_type_compensation)
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

      it 'allows to override the calculation factor for all chunks' do
        collection.total(2.0).should eq(21.hours)
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
        a.should eq(%w{test_work test_work test_onduty test_compensation})
      end
    end

    describe '#map' do
      it 'allows you to map over the chunks' do
        collection.map { |chunk| chunk.time_type.name }.should eq(%w{test_work test_work test_onduty test_compensation})
      end
    end

    describe '#empty?' do
      it 'allows you to check whether there are chunks' do
        collection.empty?.should be_false
      end
    end
  end

  context 'with chunks which have a type where the calculation factor is not 1.0' do
    let(:special_time_type) { FactoryGirl.create(:time_type, calculation_factor: 1.1) }
    let(:time_chunks) do
      [
        TimeChunk.new(starts: '2013-04-12 01:10:00'.to_time, ends: '2013-04-12 01:25:00'.to_time, time_type: special_time_type),
        TimeChunk.new(starts: '2013-04-12 02:00:00'.to_time, ends: '2013-04-12 02:45:00'.to_time, time_type: special_time_type),
        TimeChunk.new(starts: '2013-04-12 02:50:00'.to_time, ends: '2013-04-12 03:00:00'.to_time, time_type: special_time_type)
      ]
    end

    describe '#total' do
      it 'returns the total duration as the sum of the rounded duration of each chunk' do
        collection.total.should eq(17.minutes + 50.minutes + 11.minutes)
      end
    end
  end

  context 'overlapping absences' do
    describe '#total' do
      let(:user) { FactoryGirl.create(:user) }
      let(:time_sheet) { user.time_sheets.first }
      let(:absence1) { FactoryGirl.build(:absence, time_type: :vacation, start_date: '2013-03-07', end_date: '2013-03-08') }
      let(:absence2) { FactoryGirl.build(:absence, time_type: :vacation, start_date: '2013-03-07', end_date: '2013-03-07', first_half_day: true) }
      let(:time_chunks) do
        [
          TimeChunk.new(starts: '2013-03-07'.to_date.midnight, ends: '2013-03-08'.to_date.midnight, parent: absence1),
          TimeChunk.new(starts: '2013-03-08'.to_date.midnight, ends: '2013-03-09'.to_date.midnight, parent: absence1),
          TimeChunk.new(starts: '2013-03-07'.to_date.midnight, ends: '2013-03-08'.to_date.midnight, parent: absence2),
        ]
      end

      it 'counts overlapping absences as one absence' do
        collection.total.should eq(17.0.hours)
      end
    end
  end

  context 'daylight saving bounday' do
    let(:user) { FactoryGirl.create(:user) }
    let(:time_sheet) { user.time_sheets.first }
    let(:absence) { FactoryGirl.build(:absence, time_type: :vacation, start_date: '2013-03-31', end_date: '2013-03-31') }
    let(:time_chunks) { [TimeChunk.new(starts: '2013-03-31'.to_date.midnight, ends: '2013-04-01'.to_date.midnight, parent: absence)] }

    describe "#total" do
      it 'absence should count as a half/full working day even when the day is only 23 hours long (e.g. on daylight saving boundary)' do
        # e.g. when zone switches from CET to CEST on 2013-03-31, the daily length is 23 hours
        # we want the total duration to be 8.5 hours independent of this change

        # overwrite so we can work on sunday when the change occurs
        uberzeit_config = UberZeit::Config.merge({work_days:[:sunday]})
        stub_const 'UberZeit::Config', uberzeit_config

        collection.total.should eq(8.5.hours)
      end
    end
  end

  context 'non-working day' do
    let(:user) { FactoryGirl.create(:user) }
    let(:time_sheet) { user.time_sheets.first }
    let(:absence) { FactoryGirl.build(:absence, time_type: :vacation, start_date: '2013-03-24', end_date: '2013-03-24') }
    let(:time_chunks) { [TimeChunk.new(starts: '2013-03-24'.to_date.midnight, ends: '2013-03-24'.to_date.midnight, parent: absence)] }

    describe '#total' do
      it 'absence on a non-working day should not count towards the total' do
        collection.total.should eq(0)
      end
    end
  end
end
