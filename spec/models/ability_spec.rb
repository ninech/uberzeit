require 'spec_helper'
require 'cancan/matchers'

describe Ability do

  let(:team) { FactoryGirl.create(:team) }
  let(:user) { FactoryGirl.create(:user, teams: [team]) }
  let(:admin) { FactoryGirl.create(:admin, teams: [team]) }
  let(:team_leader) { FactoryGirl.create(:team_leader, teams: [team]) }

  subject { ability }

  describe 'User' do
    context 'as the user itself' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:read, user) }
      it { should be_able_to(:update, user) }

      it { should_not be_able_to(:create, User) }
      it { should_not be_able_to(:destroy, user) }
    end

    context 'as another user' do
      let(:ability) { Ability.new(FactoryGirl.create(:user)) }

      it { should_not be_able_to(:read, user) }
      it { should_not be_able_to(:update, user) }
      it { should_not be_able_to(:create, User) }
      it { should_not be_able_to(:destroy, user) }
    end

    context 'as a team leader' do
      let(:ability) { Ability.new(team_leader) }

      it { should be_able_to(:read, user) }
      it { should_not be_able_to(:update, user) }
      it { should_not be_able_to(:create, User) }
      it { should_not be_able_to(:destroy, user) }
    end
  end

  describe 'TimeType' do

    let(:time_type) { FactoryGirl.create(:time_type) }

    context 'as a user with the administration role' do
      let(:ability) { Ability.new(admin) }

      it { should be_able_to(:read, time_type) }
      it { should be_able_to(:update, time_type) }
      it { should be_able_to(:create, TimeType) }
      it { should be_able_to(:destroy, time_type) }
    end

    context 'as a normal user' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:read, time_type) }
      it { should_not be_able_to(:update, time_type) }
      it { should_not be_able_to(:create, TimeType) }
      it { should_not be_able_to(:destroy, time_type) }
    end
  end

  describe 'TimeSheet' do

    let(:time_sheet) { FactoryGirl.create(:time_sheet, user: user) }

    context 'as a user with the administration role' do
      let(:ability) { Ability.new(admin) }

      it { should be_able_to(:read, time_sheet) }
      it { should be_able_to(:update, time_sheet) }
      it { should be_able_to(:create, TimeSheet) }
      it { should be_able_to(:destroy, time_sheet) }
    end

    context 'as a team leader' do
      let(:ability) { Ability.new(team_leader) }

      it { should be_able_to(:read, time_sheet) }
      it { should be_able_to(:update, time_sheet) }
      it { should be_able_to(:destroy, time_sheet) }
    end

    context 'as the owner' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:read, time_sheet) }
      it { should be_able_to(:update, time_sheet) }
      it { should be_able_to(:create, TimeSheet) }
      it { should be_able_to(:destroy, time_sheet) }
    end

    context 'as another user' do
      let(:ability) { Ability.new(FactoryGirl.create(:user)) }

      it { should_not be_able_to(:read, time_sheet) }
      it { should_not be_able_to(:update, time_sheet) }
      it { should_not be_able_to(:destroy, time_sheet) }
    end
  end

  describe 'TimeEntry' do

    let(:time_entry) { FactoryGirl.create(:time_entry, time_sheet: user.time_sheets.first) }

    context 'as a user with the administration role' do
      let(:ability) { Ability.new(admin) }

      it { should be_able_to(:read, time_entry) }
      it { should be_able_to(:update, time_entry) }
      it { should be_able_to(:create, TimeEntry) }
      it { should be_able_to(:destroy, time_entry) }
    end

    context 'as a team leader' do
      let(:ability) { Ability.new(team_leader) }

      it { should be_able_to(:read, time_entry) }
      it { should be_able_to(:update, time_entry) }
      it { should be_able_to(:create, TimeEntry) }
      it { should be_able_to(:destroy, time_entry) }
    end

    context 'as the owner' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:read, time_entry) }
      it { should be_able_to(:update, time_entry) }
      it { should be_able_to(:create, TimeEntry) }
      it { should be_able_to(:destroy, time_entry) }
    end

    context 'as another user' do
      let(:ability) { Ability.new(FactoryGirl.create(:user)) }

      it { should_not be_able_to(:read, time_entry) }
      it { should_not be_able_to(:update, time_entry) }
      it { should_not be_able_to(:destroy, time_entry) }
    end
  end

  describe 'Absence' do

    let(:absence) { FactoryGirl.create(:absence, time_sheet: user.time_sheets.first) }

    context 'as a user with the administration role' do
      let(:ability) { Ability.new(admin) }

      it { should be_able_to(:read, absence) }
      it { should be_able_to(:update, absence) }
      it { should be_able_to(:create, Absence) }
      it { should be_able_to(:destroy, absence) }
    end

    context 'as a team leader' do
      let(:ability) { Ability.new(team_leader) }

      it { should be_able_to(:read, absence) }
      it { should be_able_to(:update, absence) }
      it { should be_able_to(:create, Absence) }
      it { should be_able_to(:destroy, absence) }
    end

    context 'as the owner' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:read, absence) }
      it { should_not be_able_to(:update, absence) }
      it { should_not be_able_to(:create, Absence) }
      it { should_not be_able_to(:destroy, absence) }
    end

    context 'as another user' do
      let(:ability) { Ability.new(FactoryGirl.create(:user)) }

      it { should_not be_able_to(:read, absence) }
      it { should_not be_able_to(:update, absence) }
      it { should_not be_able_to(:create, Absence) }
      it { should_not be_able_to(:destroy, absence) }
    end
  end

  describe 'Adjustment' do

    let(:adjustment) { FactoryGirl.create(:adjustment, time_sheet: user.time_sheets.first) }

    context 'as a user with the administration role' do
      let(:ability) { Ability.new(admin) }

      it { should be_able_to(:read, adjustment) }
      it { should be_able_to(:update, adjustment) }
      it { should be_able_to(:create, Adjustment) }
      it { should be_able_to(:destroy, adjustment) }
    end

    context 'as the owner' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:read, adjustment) }
      it { should_not be_able_to(:update, adjustment) }
      it { should_not be_able_to(:create, Adjustment) }
      it { should_not be_able_to(:destroy, adjustment) }
    end

    context 'as another user' do
      let(:ability) { Ability.new(FactoryGirl.create(:user)) }

      it { should_not be_able_to(:read, adjustment) }
      it { should_not be_able_to(:update, adjustment) }
      it { should_not be_able_to(:create, Adjustment) }
      it { should_not be_able_to(:destroy, adjustment) }
    end
  end

  describe 'Employment' do

    let(:employment) { FactoryGirl.create(:employment, user: user) }

    context 'as a user with the administration role' do
      let(:ability) { Ability.new(admin) }

      it { should be_able_to(:read, employment) }
      it { should be_able_to(:update, employment) }
      it { should be_able_to(:create, Employment) }
      it { should be_able_to(:destroy, employment) }
    end

    context 'as the owner' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:read, employment) }
      it { should_not be_able_to(:update, employment) }
      it { should_not be_able_to(:create, Employment) }
      it { should_not be_able_to(:destroy, employment) }
    end

    context 'as another user' do
      let(:ability) { Ability.new(FactoryGirl.create(:user)) }

      it { should_not be_able_to(:read, employment) }
      it { should_not be_able_to(:update, employment) }
      it { should_not be_able_to(:create, Employment) }
      it { should_not be_able_to(:destroy, employment) }
    end
  end

  describe 'Team' do
    context 'as admin' do
      let(:ability) { Ability.new(admin) }

      it { should be_able_to(:read, team) }
      it { should be_able_to(:update, team) }
      it { should be_able_to(:create, Team) }
      it { should be_able_to(:destroy, team) }
    end

    context 'as team leader' do
      let(:ability) { Ability.new(team_leader) }

      it { should be_able_to(:read, team) }
      it { should_not be_able_to(:update, team) }
      it { should_not be_able_to(:create, Team) }
      it { should_not be_able_to(:destroy, team) }
    end
  end

  describe 'Project' do

    let(:project) { FactoryGirl.create(:project) }

    context 'as a user with the administration role' do
      let(:ability) { Ability.new(admin) }

      it { should be_able_to(:read, project) }
      it { should be_able_to(:update, project) }
      it { should be_able_to(:create, Project) }
      it { should be_able_to(:destroy, project) }
    end

    context 'as a normal user' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:read, project) }
      it { should_not be_able_to(:update, project) }
      it { should_not be_able_to(:create, Project) }
      it { should_not be_able_to(:destroy, project) }
    end
  end

  describe 'ActivityType' do

    let(:activity_type) { FactoryGirl.create(:activity_type) }

    context 'as a user with the administration role' do
      let(:ability) { Ability.new(admin) }

      it { should be_able_to(:read, activity_type) }
      it { should be_able_to(:update, activity_type) }
      it { should be_able_to(:create, ActivityType) }
      it { should be_able_to(:destroy, activity_type) }
    end

    context 'as a normal user' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:read, activity_type) }
      it { should_not be_able_to(:update, activity_type) }
      it { should_not be_able_to(:create, ActivityType) }
      it { should_not be_able_to(:destroy, activity_type) }
    end
  end

  describe 'Activity' do

    let(:activity) { FactoryGirl.create(:activity, user: user) }

    context 'as a user with the administration role' do
      let(:ability) { Ability.new(admin) }

      it { should be_able_to(:read, activity) }
      it { should be_able_to(:update, activity) }
      it { should be_able_to(:destroy, activity) }
    end

    context 'as another team leader' do
      let(:another_team_leader) { FactoryGirl.create(:team_leader) }

      let(:ability) { Ability.new(another_team_leader) }

      it { should_not be_able_to(:read, activity) }
      it { should_not be_able_to(:update, activity) }
      it { should_not be_able_to(:destroy, activity) }
    end

    context 'as the team leader' do
      let(:ability) { Ability.new(team_leader) }

      context 'activity unlocked' do
        it { should be_able_to(:read, activity) }
        it { should be_able_to(:update, activity) }
        it { should be_able_to(:destroy, activity) }
      end

      context 'activity locked' do
        let(:activity) { FactoryGirl.create(:activity, user: user, locked: true) }

        it { should be_able_to(:read, activity) }
        it { should_not be_able_to(:update, activity) }
        it { should_not be_able_to(:destroy, activity) }
      end
    end

    context 'as the owner' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:create, Activity) }

      context 'activity unlocked' do
        it { should be_able_to(:read, activity) }
        it { should be_able_to(:update, activity) }
        it { should be_able_to(:destroy, activity) }
      end

      context 'activity locked' do
        let(:activity) { FactoryGirl.create(:activity, user: user, locked: true) }

        it { should be_able_to(:read, activity) }
        it { should_not be_able_to(:update, activity) }
        it { should_not be_able_to(:destroy, activity) }
      end
    end

    context 'as another user' do
      let(:ability) { Ability.new(FactoryGirl.create(:user)) }

      it { should_not be_able_to(:read, activity) }
      it { should_not be_able_to(:update, activity) }
      it { should_not be_able_to(:destroy, activity) }
    end
  end

end
