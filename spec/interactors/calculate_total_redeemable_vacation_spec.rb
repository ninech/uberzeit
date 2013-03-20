require 'spec_helper'


describe CalculateTotalRedeemableVacation do

  describe '#total_for_this_year' do

    let(:user) { FactoryGirl.create(:user, with_sheet: false) }
    let(:year) { 2013 }
    let(:vacation) { CalculateTotalRedeemableVacation.new(user, year) }

    it 'returns the total available vacations for the given year' do
      vacation.total_redeemable_for_year.should eq(25.work_days)
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

    context 'employments' do

      before do
        employment = user.employments.first
        employment.workload = 30
        employment.start_date = '2013-01-01'.to_date
        employment.end_date = '2013-03-31'.to_date # total: 90 days
        employment.save!
        FactoryGirl.create(:employment, user: user, workload: 50, start_date: '2013-04-01'.to_date, end_date: '2013-12-31'.to_date)
      end

      it 'is handles multiple employments' do
        vacation.total_redeemable_for_year.should eq(11.5.work_days) # 25*(90.0/365*0.3+275.0/365*0.5)
      end

    end

  end

end
