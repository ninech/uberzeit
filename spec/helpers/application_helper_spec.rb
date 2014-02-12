require 'spec_helper'

describe ApplicationHelper do
  describe '#display_in_hours' do
    it 'formats positive durations' do
      helper.display_in_hours(8.5.hours).should eq("08:30")
    end

    it 'formats negative durations' do
      helper.display_in_hours(-2.5.hours).should eq("-02:30")
      helper.display_in_hours(-0.5.hours).should eq("-00:30")
    end

    it 'rounds minutes' do
      helper.display_in_hours(2.hours + 1.4.minutes).should eq("02:01")
      helper.display_in_hours(2.hours + 1.5.minutes).should eq("02:02")
    end

    it 'rounds correctly' do
      helper.display_in_hours(3586).should eq("01:00")
    end
  end

  describe '#selectable_users' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:deactivated_user) { FactoryGirl.create(:user, active: false) }

    it 'won\'t include deactivated users' do
      helper.selectable_users.should_not include(deactivated_user)
    end
  end
end
