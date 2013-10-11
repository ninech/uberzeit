require 'spec_helper'

describe FetchPlannedWorkingTime do
  let(:user) { FactoryGirl.create(:user) }

  subject { FetchPlannedWorkingTime.new(user, range) }

  describe 'cold cache' do
    describe 'a week' do
      let(:range) { '2013-09-30'.to_date..'2013-10-06'.to_date }

      its(:total) { should eq(5.work_days) }

      it 'generates the needed entries in the database' do
        expect { subject.total }.to change(Day, :count)
      end
    end
  end

  describe 'warm cache' do
    let(:partial_range) { '2013-09-28'.to_date..'2013-10-01'.to_date }

    before do
      Day.create_or_regenerate_days_for_user_and_range!(user, partial_range)
    end

    describe 'a week' do
      let(:range) { '2013-09-30'.to_date..'2013-10-06'.to_date }

      its(:total) { should eq(5.work_days) }

      it 'generates the needed entries in the database' do
        expect { subject.total }.to change(Day, :count).from(4).to(9)
      end
    end
  end

  describe 'hot cache' do
    before do
      Day.create_or_regenerate_days_for_user_and_range!(user, range)
    end

    describe 'a week' do
      let(:range) { '2013-09-30'.to_date..'2013-10-06'.to_date }

      its(:total) { should eq(5.work_days) }

      it 'does not generate the entries in the database' do
        expect { subject.total }.to_not change(Day, :count)
      end
    end
  end
end
