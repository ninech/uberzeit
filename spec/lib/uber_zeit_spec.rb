require 'spec_helper'

describe UberZeit do
  before do
    FactoryGirl.create(:public_holiday, start_date: '2013-03-19', end_date: '2013-03-19', second_half_day: true) # tuesday
    FactoryGirl.create(:public_holiday, start_date: '2013-03-20', end_date: '2013-03-20') # wednesday
  end

  it '::is_work_day?' do
    UberZeit.is_work_day?('2013-03-17'.to_date).should eq(false) # sunday
    UberZeit.is_work_day?('2013-03-18'.to_date).should eq(true)
    UberZeit.is_work_day?('2013-03-19'.to_date).should eq(true)
    UberZeit.is_work_day?('2013-03-20'.to_date).should eq(false)
    UberZeit.is_work_day?('2013-03-21'.to_date).should eq(true)
  end

  it '::default_work_hours_on' do
    UberZeit.default_work_hours_on('2013-03-17'.to_date).should eq(0) # sunday
    UberZeit.default_work_hours_on('2013-03-18'.to_date).should eq(8.5.hours)
    UberZeit.default_work_hours_on('2013-03-19'.to_date).should eq(4.25.hours)
    UberZeit.default_work_hours_on('2013-03-20'.to_date).should eq(0)
    UberZeit.default_work_hours_on('2013-03-21'.to_date).should eq(8.5.hours)
  end

  it '::year_as_range' do
    range = UberZeit.year_as_range(1986)
    range.min.should eq(Date.new(1986,1,1))
    range.max.should eq(Date.new(1986,12,31))
  end
end
