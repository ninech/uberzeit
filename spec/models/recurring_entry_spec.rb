require 'spec_helper'

describe RecurringEntry do
  # it 'has a valid factory' do
  #   FactoryGirl.create(:recurring_entry).should be_valid
  # end

  # it 'acts as paranoid' do
  #   entry = FactoryGirl.create(:recurring_entry)
  #   entry.destroy
  #   expect { RecurringEntry.find(entry.id) }.to raise_error
  #   expect { RecurringEntry.with_deleted.find(entry.id) }.to_not raise_error
  # end

  # context 'setting up schedules via attributes' do
  #   before do
  #     @start_time = Time.zone.parse('2013-01-01 10:00:00 UTC')
  #     @end_time = Time.zone.parse('2013-01-01 12:00:00 UTC')
  #     @attribs = {start_time: @start_time, end_time: @end_time}
  #   end

  #   it 'ends never' do
  #     entry = FactoryGirl.create(:recurring_entry, attribs: @attribs.merge(ends: 'never'))
  #     rule = entry.schedule.rrules.first.to_hash
  #     rule[:count].should be_nil
  #     rule[:until].should be_nil
  #   end

  #   it 'ends after a certain number of occurrences' do
  #     entry = FactoryGirl.create(:recurring_entry, attribs: @attribs.merge(ends: 'counter', ends_counter: 2))
  #     rule = entry.schedule.rrules.first.to_hash
  #     rule[:count].should eq(2)
  #   end

  #   it 'ends on a certain date' do
  #     entry = FactoryGirl.create(:recurring_entry, attribs: @attribs.merge(ends: 'date', ends_date: '2013-12-31'))
  #     rule = entry.schedule.rrules.first.to_hash
  #     rule[:until].to_date.should eq('2013-12-31'.to_date)
  #   end

  #   it 'preserves the time zone information' do
  #     entry = FactoryGirl.create(:recurring_entry, attribs: @attribs)
  #     entry.schedule_hash[:start_date][:zone].should eq(Time.zone.name)
  #   end

  #   it 'is able to represent daily events' do
  #     entry = FactoryGirl.create(:recurring_entry, attribs: @attribs.merge(repeat_unit: 'daily', daily_repeat_every: 2))
  #     rule = entry.schedule.rrules.first
  #     rule.class.should eq(IceCube::DailyRule)
  #     rule.to_hash[:interval].should eq(2)
  #   end

  #   it 'is able to represent weekly events' do
  #     entry = FactoryGirl.create(:recurring_entry, attribs: @attribs.merge(repeat_unit: 'weekly', weekly_repeat_every: 3))
  #     rule = entry.schedule.rrules.first
  #     rule.class.should eq(IceCube::WeeklyRule)
  #     rule.to_hash[:interval].should eq(3)
  #   end

  #   it 'is able to represent monthly events on first day of month' do
  #     entry = FactoryGirl.create(:recurring_entry, attribs: @attribs.merge(repeat_unit: 'monthly', monthly_repeat_every: 2, monthly_repeat_by: 'day'))
  #     rule = entry.schedule.rrules.first
  #     rule.class.should eq(IceCube::MonthlyRule)
  #     rule.to_hash[:validations][:day_of_month].should eq([@start_time.day]) # 2013-01-01 first day of month
  #     rule.to_hash[:interval].should eq(2)
  #   end

  #   it 'is able to represent monthly events on first week day' do
  #     entry = FactoryGirl.create(:recurring_entry, attribs: @attribs.merge(repeat_unit: 'monthly', monthly_repeat_every: 2, monthly_repeat_by: 'weekday'))
  #     rule = entry.schedule.rrules.first
  #     rule.class.should eq(IceCube::MonthlyRule)
  #     rule.to_hash[:validations][:day_of_week].should eq({@start_time.wday => [1]}) # 2013-01-01 is a tuesday -> first tuesday of month
  #     rule.to_hash[:interval].should eq(2)
  #   end

  #   it 'is able to represent yearly events' do
  #     entry = FactoryGirl.create(:recurring_entry, attribs: @attribs.merge(repeat_unit: 'yearly', yearly_repeat_every: 1))
  #     rule = entry.schedule.rrules.first
  #     rule.class.should eq(IceCube::YearlyRule)
  #     rule.to_hash[:interval].should eq(1)
  #   end
  # end
end
