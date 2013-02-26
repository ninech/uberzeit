require 'spec_helper'

describe TimeSheet do
  before do
    @sheet = FactoryGirl.create(:time_sheet)
    @sheet.single_entries.clear
    @week = (Time.zone.today.at_beginning_of_week..Time.zone.today.next_week)
  end

  it 'has a valid factory' do
    @sheet.should be_valid
  end

  it 'acts as paranoid' do
    @sheet.destroy
    expect { TimeSheet.find(@sheet.id) }.to raise_error
    expect { TimeSheet.with_deleted.find(@sheet.id) }.to_not raise_error
  end

  it 'delivers single entries on a per-chunk basis' do
    # lets add some entries to the sheet
    ref_date = Time.zone.now.at_beginning_of_week.to_date
    ref_time = ref_date.midnight
    @sheet.single_entries << FactoryGirl.create(:single_entry, start: ref_time + 12.hours, duration: 6.hours, type: :break)
    @sheet.single_entries << FactoryGirl.create(:single_entry, start: ref_time + 18.hours, duration: 24.hours, type: :work)

    @sheet.find_chunks(ref_date, :work).first.duration.should eq(6.hours) 
    @sheet.find_chunks(ref_date + 1.day, :work).first.duration.should eq(18.hours)
    @sheet.find_chunks((ref_date..ref_date+2.days), :work).first.duration.should eq(24.hours)
  end

  it 'calculates the work duration (daily and weekly)' do
    ref_date = Time.zone.now.at_beginning_of_week.to_date
    ref_time = ref_date.midnight
    @sheet.single_entries << FactoryGirl.create(:single_entry, start: ref_time + 8.hours, duration: 4.hours, type: :work)
    @sheet.single_entries << FactoryGirl.create(:single_entry, start: ref_time + 12.hours, duration: 0.5.hours, type: :break)
    @sheet.single_entries << FactoryGirl.create(:single_entry, start: ref_time + 12.5.hours, duration: 4.5.hours, type: :work)

    next_date = ref_date + 1.day
    next_time = next_date.midnight
    @sheet.single_entries << FactoryGirl.create(:single_entry, start: next_time + 0.hours, duration: 6.hours, type: :work)
    @sheet.single_entries << FactoryGirl.create(:single_entry, start: next_time + 7.hours, duration: 0.5.hours, type: :break)
    @sheet.single_entries << FactoryGirl.create(:single_entry, start: next_time + 7.5.hours, duration: 3.5.hours, type: :work)

    @sheet.total(ref_date, :work).should eq(8.5.hours)
    @sheet.total(next_date, :work).should eq(9.5.hours)
    @sheet.total((ref_date..ref_date+7.days), :work).should eq(18.0.hours)
  end

  context 'user with full-time workload' do
    it 'calculates the weekly overtime duration' do
      ref_date = Time.zone.now.at_beginning_of_week.to_date
      ref_time = ref_date.midnight
      @sheet.single_entries << FactoryGirl.create(:single_entry, start: ref_time + 8.hours, duration: 12.hours, type: :work)

      next_date = ref_date + 1.day
      next_time = next_date.midnight
      @sheet.single_entries << FactoryGirl.create(:single_entry, start: next_time + 8.hours, duration: 8.hours, type: :work)

      next_date = ref_date + 2.day
      next_time = next_date.midnight
      @sheet.single_entries << FactoryGirl.create(:single_entry, start: next_time + 23.hours, duration: 1.hours, type: :work)

      work_quota = UberZeit::Config[:work_days].length * UberZeit::Config[:work_per_day]
      @sheet.overtime((ref_date..ref_date+7.days)).should eq(21.hours - work_quota)
    end

    it 'calculates the daily overtime duration' do

      ref_date = Time.zone.now.at_beginning_of_week.to_date
      ref_time = ref_date.midnight
      @sheet.single_entries << FactoryGirl.create(:single_entry, start: ref_time + 8.hours, duration: 12.hours, type: :work)

      @sheet.overtime(ref_date).should eq(12.hours - UberZeit::Config[:work_per_day])
    end

    it 'calculates the number of redeemed vacation days for the year' do
      ref_date = Time.zone.now.at_beginning_of_week.to_date
      ref_time = ref_date.midnight
      @sheet.single_entries << FactoryGirl.create(:single_entry, start: ref_time, whole_day: true, type: :vacation)
      @sheet.single_entries << FactoryGirl.create(:single_entry, start: ref_time + 2.days, duration: 0.5.work_days, type: :vacation)
      @sheet.vacation(ref_date.year).should eq(1.5.work_days)
    end

    it 'calculates the number of remaining vacation days for the year' do
      ref_date = Time.zone.now.at_beginning_of_week.to_date
      ref_time = ref_date.midnight
      @sheet.single_entries << FactoryGirl.create(:single_entry, start: ref_time, whole_day: true, type: :vacation)
      @sheet.remaining_vacation(ref_date.year).should eq(UberZeit::total_vacation(@sheet.user, ref_date.year)-1.work_days)
    end
  end

  context 'user with part-time workload' do
    # TODO comment why we expect what
    before do
      @workload = 40
      employment = @sheet.user.employments.first
      employment.workload = 40
      employment.save!

      @weekly_work_quota = UberZeit::Config[:work_days].length * @workload * 0.01 * UberZeit::Config[:work_per_day]
    end

    it 'calculates the weekly overtime duration' do
      ref_date = Time.zone.now.at_beginning_of_week.to_date
      ref_time = ref_date.midnight
      @sheet.single_entries << FactoryGirl.create(:single_entry, start: ref_time + 8.hours, duration: 12.hours, type: :work)

      next_date = ref_date + 1.day
      next_time = next_date.midnight
      @sheet.single_entries << FactoryGirl.create(:single_entry, start: next_time + 8.hours, duration: 8.hours, type: :work)

      @sheet.overtime((ref_date..ref_date+7.days)).should eq(20.hours - @weekly_work_quota)
    end

    it 'calculates the daily overtime duration' do
      ref_date = Time.zone.now.at_beginning_of_week.to_date
      ref_time = ref_date.midnight
      @sheet.single_entries << FactoryGirl.create(:single_entry, start: ref_time + 8.hours, duration: 10.hours, type: :work)
      @sheet.overtime(ref_date).should eq([10.hours - @weekly_work_quota,0].max)

      next_date = ref_date + 1.day
      next_time = next_date.midnight
      @sheet.single_entries << FactoryGirl.create(:single_entry, start: next_time + 8.hours, duration: 14.hours, type: :work)
      @sheet.overtime(next_date).should eq([24.hours - @weekly_work_quota,0].max)
    end


    it 'calculates the number of remaining vacation days for the year' do
      ref_date = Time.zone.now.at_beginning_of_week.to_date
      ref_time = ref_date.midnight
      @sheet.single_entries << FactoryGirl.create(:single_entry, start: ref_time, whole_day: true, type: :vacation)
      @sheet.remaining_vacation(ref_date.year).should eq(UberZeit::total_vacation(@sheet.user, ref_date.year)-1.work_days)
    end
  end


end