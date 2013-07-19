# == Schema Information
#
# Table name: exception_dates
#
#  id                    :integer          not null, primary key
#  recurring_schedule_id :integer
#  date                  :date
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'spec_helper'

describe ExceptionDate do
  it 'has a valid factory' do
    FactoryGirl.build(:exception_date).should be_valid
  end

  context '#in' do
    before do
      @exception_date_1 = FactoryGirl.create(:exception_date, date: '2013-07-20')
      @exception_date_2 = FactoryGirl.create(:exception_date, date: '2013-07-21')
      @exception_date_3 = FactoryGirl.create(:exception_date, date: '2013-07-22')
      @exception_date_4 = FactoryGirl.create(:exception_date, date: '2013-08-01')
    end

    it 'returns the exception dates in the given range' do
      ExceptionDate.in('2013-07-20'.to_date..'2013-07-21'.to_date).should =~ [@exception_date_1, @exception_date_2]
    end
  end
end
