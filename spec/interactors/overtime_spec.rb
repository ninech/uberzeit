require 'spec_helper'

describe Overtime do

  let(:user) { FactoryGirl.create(:user) }
  let(:date) { '2013-03-12'.to_date }
  let(:range) { '2013-03-12'.to_date...'2013-03-14'.to_date }
  let(:time_sheet) { user.current_time_sheet }

  def work(start_time, end_time)
    FactoryGirl.create(:time_entry, start_time: start_time.to_time, end_time: end_time.to_time, type: :work, time_sheet: time_sheet)
  end

  def vacation(start_time, end_time)
    FactoryGirl.create(:time_entry, start_time: start_time.to_time, end_time: end_time.to_time, type: :vacation, time_sheet: time_sheet)
  end

  context 'full time employment' do
    it 'calculates the overtime for a date' do
      work '2013-03-12 9:00:00', '2013-03-12 18:00:00'
      Overtime.new(user, date).total.should eq(0.5.hours)
    end

    it 'calculates the overtime for a range' do
      work '2013-03-12 9:00:00', '2013-03-12 18:00:00'
      work '2013-03-13 9:00:00', '2013-03-13 18:30:00'
      Overtime.new(user, range).total.should eq(1.5.hours)
    end

    it 'calculates the undertime' do
      work '2013-03-12 9:00:00', '2013-03-12 12:30:00'
      Overtime.new(user, date).total.should eq(-5.hours)
    end
  end

  context 'part time employment' do

    let(:employment) { user.current_employment }
    before do
      employment.workload = 50
      employment.save
    end

    it 'calculates the overtime for a date' do
      work '2013-03-12 9:00:00', '2013-03-12 13:30:00'
      Overtime.new(user, date).total.should eq(0.25.hours)
    end

    it 'calculates the overtime for a range' do
      work '2013-03-12 9:00:00', '2013-03-12 13:30:00'
      work '2013-03-13 9:00:00', '2013-03-13 14:30:00'
      Overtime.new(user, range).total.should eq(1.5.hours)
    end

    it 'calculates the undertime' do
      work '2013-03-12 9:00:00', '2013-03-12 10:30:00'
      Overtime.new(user, date).total.should eq(-2.75.hours)
    end
  end

end
