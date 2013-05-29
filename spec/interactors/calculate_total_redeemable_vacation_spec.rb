require 'spec_helper'


describe CalculateTotalRedeemableVacation do

  describe '#total_redeemable_for_year' do
    let(:user) { FactoryGirl.create(:user, with_sheet: true) }
    let(:time_sheet) { user.current_time_sheet }
    let(:year) { 2013 }
    let(:vacation) { CalculateTotalRedeemableVacation.new(user, year) }

    it 'returns the total available vacations for the given year' do
      vacation.total_redeemable_for_year.should eq(25.work_days)
    end

    it 'returns 0 for a year without employment' do
      vacation = CalculateTotalRedeemableVacation.new(user, 1986)
      vacation.total_redeemable_for_year.should eq(0)
    end

    context 'rounding' do
      it 'handles 55% correctly' do
        employment = user.employments.first
        employment.workload = 55
        employment.save!
        vacation.total_redeemable_for_year.should eq(14.work_days)
      end

      it 'handles 53% correctly' do
        employment = user.employments.first
        employment.workload = 53
        employment.save!
        vacation.total_redeemable_for_year.should eq(13.5.work_days)
      end
    end

    context 'multiple employments' do
      before do
        employment = user.employments.first
        employment.workload = 30
        employment.start_date = '2013-01-01'.to_date
        employment.end_date = '2013-03-31'.to_date
        employment.save!

        # create second employment
        FactoryGirl.create(:employment, user: user, workload: 50, start_date: '2013-04-01'.to_date, end_date: '2013-12-31'.to_date)
      end

      it 'returns the correct value for multiple employments' do
        vacation.total_redeemable_for_year.should eq(11.5.work_days)
      end
    end

    context 'employment starts in the middle of the month' do
      before do
        employment = user.employments.first
        employment.workload = 100
        employment.start_date = '2013-01-21'.to_date
        employment.end_date = '2013-12-31'.to_date
        employment.save!
      end

      it 'returns the reedemable year' do
        # total 261 work days (excluding public holidays)
        # test employment starts after 14 already elapsed working days
        vacation.total_redeemable_for_year(false).should be_within(0.1).of(25.work_days * (261-14).to_f/261.to_f)
      end
    end

    context 'adjustments' do
      it 'includes adjustments for vacation' do
        adjustment = FactoryGirl.create(:adjustment, time_sheet: time_sheet, time_type: TEST_TIME_TYPES[:vacation], duration: 5.work_days, date: '2013-07-20')
        vacation.total_redeemable_for_year.should eq(30.work_days)
      end
    end
  end

end
