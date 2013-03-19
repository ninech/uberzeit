require 'spec_helper'

describe CalculateWorkingTime do
  let(:user) { FactoryGirl.create(:user) }
  let(:date) { '2013-03-12'.to_date }
  let(:range) { '2013-03-12'.to_date...'2013-03-14'.to_date }
  let(:time_sheet) { user.current_time_sheet }

  def work(start_time, end_time)
    FactoryGirl.create(:time_entry, start_time: start_time.to_time, end_time: end_time.to_time, time_type: :work, time_sheet: time_sheet)
  end

  def vacation(start_date, end_date)
    FactoryGirl.create(:absence, start_date: start_date.to_date, end_date: end_date.to_date, time_type: :vacation, time_sheet: time_sheet)
  end

  it 'calculates the working time for a date' do
    work '2013-03-12 9:00:00', '2013-03-12 18:00:00'
    CalculateWorkingTime.new(time_sheet, date).total.should eq(9.0.hours)
  end

  it 'calculates the working time for a range' do
    work '2013-03-12 9:00:00', '2013-03-12 18:00:00'
    vacation '2013-03-13', '2013-03-13'
    CalculateWorkingTime.new(time_sheet, range).total.should eq(9.hours + 8.5.hours)
  end
end
