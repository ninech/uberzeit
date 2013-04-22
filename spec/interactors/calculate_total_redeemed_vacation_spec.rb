require 'spec_helper'

describe CalculateTotalRedeemedVacation do
  def vacation(start_date, end_date, daypart = :whole_day)
    FactoryGirl.create(:absence, start_date: start_date.to_date, end_date: end_date.to_date, time_type: :vacation, time_sheet: time_sheet, daypart: daypart)
  end

  describe '#total' do
    let(:user) { FactoryGirl.create(:user) }
    let(:time_sheet) { user.current_time_sheet }
    let(:range) { Date.new(2013,1,1)..Date.new(2013,12,31) }
    let(:redeemed) { CalculateTotalRedeemedVacation.new(user, range) }

    before do
      vacation('2013-04-22', '2013-04-24')
    end

    it 'returns the total redeemed vacation days for the given range' do
      redeemed.total.should eq(3.work_days)
    end
  end

end
