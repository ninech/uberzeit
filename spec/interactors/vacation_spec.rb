require 'spec_helper'


describe Vacation do

  describe '#total_for_this_year' do

    let(:user) { FactoryGirl.create(:user, with_sheet: false) }
    let(:year) { 2013 }
    let(:vacation) { Vacation.new(user, year) }

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

  end

end
