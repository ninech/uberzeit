require 'spec_helper'

describe SummarizeTimeSheet do

  let(:user) { FactoryGirl.create(:user) }
  let(:time_sheet) { user.current_time_sheet }

  def work(start_time, end_time)
    FactoryGirl.create(:time_entry, start_time: start_time.to_time, end_time: end_time.to_time, time_type: :work, time_sheet: time_sheet)
  end

  def vacation(start_date, end_date)
    FactoryGirl.create(:absence, start_date: start_date.to_date, end_date: end_date.to_date, time_type: :vacation, time_sheet: time_sheet)
  end

  context 'work' do
    before :all do
      work '2013-03-25 09:00:00', '2013-03-25 12:00:00'
      work '2013-03-25 12:30:00', '2013-03-25 18:00:00'

      summarize = SummarizeTimeSheet.new(time_sheet, 2013, 1.month)
      @rows, @total = summarize.work
      @month_row = @rows[2]
    end

    context 'for each row' do
      it 'returns the worked time' do
        @month_row[:worked].should eq(8.5.hours)
      end

      it 'returns the time by time type' do
        @month_row[:by_type]['test_work'].should eq(8.5.hours)
      end

      it 'returns the planned working time' do
        @month_row[:planned].should eq(21 * 8.5.hours)
      end

      it 'returns the overtime' do
        @month_row[:overtime].should eq(-20 * 8.5.hours)
      end

      it 'returns the running sum of the overtime' do
        @month_row[:sum].should eq(-(23+20+20) * 8.5.hours)
      end

      it 'returns the range' do
        @month_row[:range].should eq(Date.new(2013,3,1)..Date.new(2013,3,31))
      end
    end
  end

  context 'absence' do
    before :all do
      vacation '2013-02-11', '2013-02-13'
      vacation '2013-03-25', '2013-03-28'

      summarize = SummarizeTimeSheet.new(time_sheet, 2013, 1.month)
      @rows, @total = summarize.absence
      @month_row = @rows[2]
    end

    it 'returns the total absence time for a type' do
      @total[TEST_TIME_TYPES[:vacation].id].should eq(7*8.5.hours)
    end

    context 'for each row' do
      it 'returns the range' do
        @month_row[:range].should eq(Date.new(2013,3,1)..Date.new(2013,3,31))
      end

      it 'returns the absence time for' do
        @month_row[TEST_TIME_TYPES[:vacation].id].should eq(4*8.5.hours)
      end
    end
  end
end
