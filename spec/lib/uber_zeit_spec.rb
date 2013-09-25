require 'spec_helper'

describe UberZeit do
  before do
    FactoryGirl.create(:public_holiday, date: '2013-03-19', second_half_day: true) # tuesday
    FactoryGirl.create(:public_holiday, date: '2013-03-20') # wednesday
  end

  it '::is_weekday_a_workday?' do
    UberZeit.is_weekday_a_workday?('2013-03-17'.to_date).should eq(false)
    UberZeit.is_weekday_a_workday?('2013-03-18'.to_date).should eq(true)
    UberZeit.is_weekday_a_workday?('2013-03-19'.to_date).should eq(true)
    UberZeit.is_weekday_a_workday?('2013-03-20'.to_date).should eq(true)
    UberZeit.is_weekday_a_workday?('2013-03-21'.to_date).should eq(true)
  end

  it '::is_work_day?' do
    UberZeit.is_work_day?('2013-03-17'.to_date).should eq(false) # sunday
    UberZeit.is_work_day?('2013-03-18'.to_date).should eq(true)
    UberZeit.is_work_day?('2013-03-19'.to_date).should eq(true)
    UberZeit.is_work_day?('2013-03-20'.to_date).should eq(false) # holiday
    UberZeit.is_work_day?('2013-03-21'.to_date).should eq(true) # half holiday
  end

  it '::year_as_range' do
    range = UberZeit.year_as_range(1986)
    range.min.should eq(Date.new(1986,1,1))
    range.max.should eq(Date.new(1986,12,31))
  end

  it '::month_as_range' do
    range = UberZeit.month_as_range(1986,7)
    range.min.should eq(Date.new(1986,7,1))
    range.max.should eq(Date.new(1986,7,31))
  end

  it '::round' do
    UberZeit.round(10.5.minutes, 1.minute).should eq(11.minutes)
    UberZeit.round(77.minutes, 15.minutes).should eq(75.minutes)
  end

  it '::duration_in_hhmm' do
    UberZeit.duration_in_hhmm(4.5.hours).should eq('04:30')
    UberZeit.duration_in_hhmm(-1.25.hours).should eq('-01:15')
  end

  it '::hhmm_in_duration' do
    UberZeit.hhmm_in_duration('04:30').should eq(4.5.hours)
    UberZeit.hhmm_in_duration('-00:15').should eq(-0.25.hours)
  end
end
