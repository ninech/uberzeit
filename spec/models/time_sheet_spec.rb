# == Schema Information
#
# Table name: time_sheets
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

require 'spec_helper'

describe TimeSheet do

  let(:user) { FactoryGirl.create(:user) }
  let(:time_sheet) { user.time_sheet }

  def work(start_time, end_time)
    FactoryGirl.create(:time_entry, starts: start_time.to_time, ends: end_time.to_time, time_type: :work, user: user)
  end

  def vacation(start_date, end_date, daypart = :whole_day)
    FactoryGirl.create(:absence, start_date: start_date.to_date, end_date: end_date.to_date, time_type: :vacation, user: user, daypart: daypart)
  end

  def paid_absence(start_date, end_date, daypart = :whole_day)
    FactoryGirl.create(:absence, start_date: start_date.to_date, end_date: end_date.to_date, time_type: :paid_absence, user: user, daypart: daypart)
  end

  context 'time-sheet with a complex weekly schedule (time entries)' do
    before do
      @stats = {}

      # sunday previous week (night shift)
      work '2013-02-03 18:00:00 GMT+1', '2013-02-04 00:00:00 GMT+1'

      # monday
      work '2013-02-04 09:00:00 GMT+1', '2013-02-04 12:00:00 GMT+1'
      work '2013-02-04 12:30:00 GMT+1', '2013-02-04 18:00:00 GMT+1'
      # @stats['2013-02-04'] = { num_work_entries: 2, work: 8.5.hours, overtime: 0, vacation: 0 }

      # tuesday, one day closer to the weekend
      work '2013-02-05 09:00:00 GMT+1', '2013-02-05 12:00:00 GMT+1'
      work '2013-02-05 12:30:00 GMT+1', '2013-02-05 16:30:00 GMT+1'
      # @stats['2013-02-05'] = { num_work_entries: 2, work: 7.hours, overtime: 0, vacation: 0 }

      # wednesday we take a day off
      vacation '2013-02-06', '2013-02-06'
      # @stats['2013-02-06'] = { num_work_entries: 0, work: 0, overtime: 0, vacation: 1.work_days }

      # thursday we decide to work through the night
      work '2013-02-07 16:00:00 GMT+1', '2013-02-07 18:00:00 GMT+1'
      work '2013-02-07 20:00:00 GMT+1', '2013-02-08 03:00:00 GMT+1'
      # @stats['2013-02-07'] = { num_work_entries: 2, work: 6.hours, overtime: 0, vacation: 0 }

      # thank god it's friday
      work '2013-02-08 12:00:00 GMT+1', '2013-02-08 19:00:00 GMT+1'
      # @stats['2013-02-08'] = { num_work_entries: 1, work: 10.hours, overtime: 1.5.hours, vacation: 0 }

      # saturday off

      # sunday we decide to work, just for fun
      work '2013-02-10 22:00:00 GMT+1', '2013-02-11 00:00:00 GMT+1'
      # @stats['2013-02-10'] = { num_work_entries: 1, work: 2.hours, overtime: 0, vacation: 0 }

      # monday next week begins early
      work '2013-02-11 00:00:00 GMT+1', '2013-02-11 06:00:00 GMT+1'

      # tue-wed next week free
      vacation '2013-02-12', '2013-02-13'
    end

    context 'user with full-time workload' do
      it 'delivers single entries which are cut to the specified date or range (chunks)' do
        time_sheet.find_chunks('2013-02-04'.to_date...'2013-02-11'.to_date, TimeType.work).length.should eq(8)

        # we work edthrough the night on 02-07 so we expect two chunks for 02-08
        time_sheet.find_chunks('2013-02-08'.to_date, TimeType.work).length.should eq(2)

        # check sunday for borderline
        time_sheet.find_chunks('2013-02-10'.to_date, TimeType.work).length.should eq(1)

        # what about times and timezones?
        time_sheet.find_chunks('2013-02-04 00:00:00 GMT+1'.to_time..'2013-02-04 09:00:00 GMT+1'.to_time).should be_empty
        time_sheet.find_chunks('2013-02-04 00:00:00 GMT+1'.to_time..'2013-02-04 09:05:00 GMT+1'.to_time).should_not be_empty
      end

      it 'calculates the total duration (daily and weekly)' do
        time_sheet.total('2013-02-04'.to_date...'2013-02-11'.to_date, TimeType.work).should eq(33.5.hours)
        time_sheet.total('2013-02-04'.to_date...'2013-02-11'.to_date, TimeType.vacation).should eq(1.work_days)

        # what about times and timezones?
        time_sheet.total('2013-02-04 10:00:00 GMT+1'.to_time..'2013-02-10 22:00:00 GMT+1'.to_time, TimeType.work).should eq(30.5.hours)
      end

      it 'calculates the weekly overtime duration' do
        time_sheet.overtime('2013-02-04'.to_date...'2013-02-11'.to_date).should eq(-0.5.hours)
      end

      it 'calculates the daily overtime duration' do
        time_sheet.overtime('2013-02-08'.to_date).should eq(1.5.hours)
      end

      it 'calculates the number of redeemed vacation days for the year' do
        time_sheet.vacation(2013).should eq(3.0.work_days)
      end

      it 'calculates the number of remaining vacation days for the year' do
        time_sheet.remaining_vacation(2013).should eq(22.0.work_days)
      end

    end

    context 'user with part-time workload' do
      # TODO comment why we expect what
      before do
        employment = user.employments.first
        employment.workload = 50
        employment.save
      end

      it 'calculates the weekly overtime duration' do
        time_sheet.overtime('2013-02-04'.to_date...'2013-02-11'.to_date).should eq(20.75.hours)
      end

      it 'calculates the number of redeemed vacation days for the year' do
        time_sheet.vacation(2013).should eq(3.0.work_days)
      end

      it 'calculates the number of remaining vacation days for the year' do
        time_sheet.remaining_vacation(2013).should eq(9.5.work_days)
      end
    end
  end

  context 'time-sheet with both one time and recurring entries plus holidays' do
    before do
      # recurring entry every monday paid absence for 4 weeks
      absence_entry = paid_absence('2013-03-04', '2013-03-04')
      absence_entry.schedule.update_attributes(active: true, ends: 'counter', ends_counter: 4, weekly_repeat_interval: 1)

      # tuesday vacation
      vacation '2013-03-19', '2013-03-19'
      # wednesday morning off
      vacation '2013-03-20', '2013-03-20', :first_half_day
      work '2013-03-20 13:00:00 GMT+1', '2013-03-20 17:15:00 GMT+1'
      # thursday is a normal work day
      work '2013-03-21 08:00:00 GMT+1', '2013-03-21 12:00:00 GMT+1'
      work '2013-03-21 12:30:00 GMT+1', '2013-03-21 17:00:00 GMT+1'
      # and friday is a public holiday, what a lovely week!
      # (public holidays are not counted as work days)
      FactoryGirl.create(:public_holiday, date: '2013-03-22')
    end

    it 'calculates the work time' do
      time_sheet.work('2013-03-18'.to_date...'2013-03-25'.to_date).should eq(34.hours)
    end

    it 'calculates the overtime' do
      time_sheet.overtime('2013-03-18'.to_date...'2013-03-25'.to_date).should eq(0)
    end
  end

  it 'will not mark vacation days as redeemed if they overlap with public holidays' do
    FactoryGirl.create(:public_holiday, date: '2013-08-01', name: '"Proud to be a swiss"-day')
    vacation '2013-07-29', '2013-08-11'
    time_sheet.vacation(2013).should eq(9.work_days)
  end
end
