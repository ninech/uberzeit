# encoding: utf-8
require 'spec_helper'

describe 'taking a look at the activities' do
  include RequestHelpers

  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    Timecop.travel('2013-07-16 12:00:00 +0200')
    # last week:
    FactoryGirl.create_list(:activity, 2, user: user, duration: 1800, date: '2013-07-14')
    # this week, yesterday:
    FactoryGirl.create_list(:activity, 1, user: user, duration: 1800, date: '2013-07-15')
    # this week, today:
    FactoryGirl.create_list(:activity, 3, user: user, duration: 1600, date: '2013-07-16')
    login user
  end

  describe 'user\'s activity overview' do
    context 'without date parameter' do
      before(:each) do
        visit user_activities_path(user)
      end

      it 'calculates the total duration for the current day' do
        page.should have_content('Total 01:20')
      end

      it 'calculates the total duration for the current week' do
        page.should have_content('Total 01:50')
      end

      it 'calculates the total for this week\'s days' do
        page.should have_content('15. Jul 00:30')
        page.should have_content('16. Jul 01:20')
      end

      it 'does not show the total for of days in the last week' do
        page.should_not have_content('14. Jul 01:00')
      end
    end
  end
end
