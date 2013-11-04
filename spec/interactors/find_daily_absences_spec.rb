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

  describe '#result' do
    subject { find_absences.result }

    it 'finds absences in the given range' do
      subject.should =~ [absence1, absence2]
    end
  end

  describe '#result_grouped_by_date' do
    subject { find_absences.result_grouped_by_date }

    it 'finds absences in the given range' do
      subject[from].should =~ [absence1, absence2]
    end

    describe 'sorting' do
      before do
        FactoryGirl.create(:absence, user: user1, start_date: '2013-01-01', end_date: '2013-01-01')
        FactoryGirl.create(:absence, user: user1, start_date: '2013-12-31', end_date: '2013-12-31') # later created
      end

      let(:find_absences) { FindDailyAbsences.new([user1, user2], '2013-01-01'.to_date..'2013-12-31'.to_date) }

      it 'is a sorted hash' do
        subject.keys.should eq subject.keys.sort
      end
    end

    context 'with one user' do
      let(:find_absences) { FindDailyAbsences.new(user1, range) }

      it 'can handle one user' do
        subject[from].should =~ [absence1]
      end
    end
  end

end
