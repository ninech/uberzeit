require 'spec_helper'

describe FindDailyAbsences do
  let(:from) { '2013-07-20'.to_date }
  let(:to) { '2013-07-21'.to_date }

  let(:range) { from..to }

  let(:user1) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }

  let!(:absence1) { FactoryGirl.create(:absence, user: user1, start_date: '2013-07-16', end_date: '2013-07-20') }
  let!(:absence2) { FactoryGirl.create(:absence, user: user2, start_date: '2013-07-20', end_date: '2013-07-22') }

  let(:find_absences) { FindDailyAbsences.new([user1, user2], range) }

  it 'finds absences in the given range' do
      find_absences.result[from].should have(2).chunks
      find_absences.result[from].collect(&:id).should =~ [absence1.id, absence2.id]
  end

end
