require 'spec_helper'

describe PlannedWorkCalculator do

  let(:calculator) { PlannedWorkCalculator.new(user, date_or_range) }
  let(:user) { FactoryGirl.create(:user, with_employment: false, with_sheet: false) }


  describe 'with a date' do
    let(:date_or_range) { '2013-03-06'.to_date }

    context 'employment dependent' do
      it 'returns the planned work for a full time employment' do
        FactoryGirl.create(:employment, workload: 100, user: user)
        calculator.employment_dependent.should eq(8.5.hours)
      end

      it 'returns the planned work for a part time employment' do
        FactoryGirl.create(:employment, workload: 50, user: user)
        calculator.employment_dependent.should eq((8.5/2).hours)
      end

      it 'returns zero if the user did not have an employment' do
        FactoryGirl.create(:employment, start_date: '2014-01-01'.to_date, user: user)
        calculator.employment_dependent.should eq(0)
      end
    end

    context 'force fulltime employment' do
      it 'returns fulltime employment planned work for a full time employment' do
        FactoryGirl.create(:employment, workload: 100, user: user)
        calculator.fulltime_employment.should eq(8.5.hours)
      end

      it 'returns fulltime employment planned work for a part time employment' do
        FactoryGirl.create(:employment, workload: 50, user: user)
        calculator.fulltime_employment.should eq(8.5.hours)
      end

      it 'returns zero if the user did not have an employment' do
        FactoryGirl.create(:employment, start_date: '2014-01-01'.to_date, user: user)
        calculator.fulltime_employment.should eq(0)
      end
    end

  end

  shared_examples_for 'range' do

    context 'employment dependent' do
      it 'returns the planned work for a full time employment' do
        FactoryGirl.create(:employment, workload: 100, user: user)
        calculator.employment_dependent.should eq(5*8.5.hours)
      end
      it 'returns the planned work for a part time employment' do
        FactoryGirl.create(:employment, workload: 50, user: user)
        calculator.employment_dependent.should eq((5*8.5/2).hours)
      end

      it 'returns zero if the user did not have an employment' do
        FactoryGirl.create(:employment, start_date: '2014-01-01'.to_date, user: user)
        calculator.employment_dependent.should eq(0)
      end
    end

    context 'force fulltime employment' do
      it 'returns fulltime employment planned work for a full time employment' do
        FactoryGirl.create(:employment, workload: 100, user: user)
        calculator.fulltime_employment.should eq(5*8.5.hours)
      end

      it 'returns fulltime employment planned work for a part time employment' do
        FactoryGirl.create(:employment, workload: 50, user: user)
        calculator.fulltime_employment.should eq(5*8.5.hours)
      end

      it 'returns zero if the user did not have an employment' do
        FactoryGirl.create(:employment, start_date: '2014-01-01'.to_date, user: user)
        calculator.fulltime_employment.should eq(0)
      end
    end
  end

  describe 'exclusive range' do
    let(:date_or_range) { '2013-03-04'.to_date...'2013-03-09'.to_date }
    it_behaves_like 'range'
  end

  describe 'inclusive range' do
    let(:date_or_range) { '2013-03-04'.to_date..'2013-03-09'.to_date }
    it_behaves_like 'range'
  end

end
