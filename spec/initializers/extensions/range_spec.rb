require 'spec_helper'

# Testing the monkey patches here
describe Range do
  it 'intersects times' do
    time_now = Time.zone.now
    range1 = time_now..time_now+2.hours
    range2 = time_now+0.5.hours..time_now+3.hours

    range1.intersect(range2).duration.should eq(1.5.hours)
  end

  it 'intersects dates' do
    range1 = '2013-07-20'.to_date..'2013-07-22'.to_date
    range2 = '2013-07-22'.to_date..'2013-07-31'.to_date

    range1.intersect(range2).duration.should eq(1.day)
  end

  it 'intersects date and time' do
    range1 = '2013-07-20'.to_date..'2013-07-22'.to_date
    range2 = Time.zone.parse('2013-07-18 00:00:00')..Time.zone.parse('2013-07-21 12:00:00')

    range1.intersect(range2).duration.should eq(36.hours)
  end

  context 'to_date_range' do
    context 'when date range supplied' do
      it 'returns a copy of the same range' do
        range = (Date.today..Date.tomorrow)
        range.to_date_range.should eq(range)
      end
    end

    context 'when a range with strings is supplied' do
      it 'parses the strings as dates' do
        range = ('2013-07-20'..'2013-07-22')
        range.to_date_range.should eq(Date.new(2013,7,20)..Date.new(2013,7,22))
      end
    end

    context 'when a time range is supplied where the max time is at midnight' do
      it 'returns a date which excludes the max\' date (and thus only includes elapsed days)' do
        range = (Time.parse('2013-07-20 00:00:00')..Time.parse('2013-07-23 00:00:00'))
        range.to_date_range.should eq(Date.new(2013,7,20)..Date.new(2013,7,22))
      end
    end

    context 'when a time range is supplied where the max time is after midnight' do
      it 'returns a date which includes the max\' date (and thus only includes elapsed days)' do
        range = (Time.parse('2013-07-20 00:00:00')..Time.parse('2013-07-23 12:00:00'))
        range.to_date_range.should eq(Date.new(2013,7,20)..Date.new(2013,7,23))
      end
    end
  end

  context 'to_time_range' do
    context 'when date range supplied' do
      it 'handles the max date as including and returns a time range in the current time zone' do
        # the following date range is 48 hours (end date is inclusive)
        range = (Date.today..Date.tomorrow)
        range.to_time_range.should eq(Time.zone.now.midnight..Time.zone.now.midnight + 48.hours)
      end
    end

    context 'when a range with strings is supplied' do
      it 'parses the strings as times' do
        range = ('2013-07-20 07:00:00'..'2013-07-22 12:00:00')
        range.to_time_range.should eq(Time.zone.parse('2013-07-20 07:00:00')..Time.zone.parse('2013-07-22 12:00:00'))
      end
    end

    context 'when a time range is supplied' do
      it 'returns a copy of the same range' do
        range = (Time.zone.now..Time.zone.now + 2.hours)
        range.to_time_range.should eq(range)
      end
    end
  end
end
