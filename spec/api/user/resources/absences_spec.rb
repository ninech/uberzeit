require 'spec_helper'

describe API::User::Resources::Absences do
  include Warden::Test::Helpers

  let(:api_user) { FactoryGirl.create(:user) }
  let(:json) { JSON.parse(response.body) }

  before do
    login_as api_user
  end

  describe 'GET /api/absences' do
    let!(:team_member) { FactoryGirl.create(:user, teams: api_user.teams)}
    let!(:own_vacation) { FactoryGirl.create(:absence, user: api_user, start_date: '2013-07-19', end_date: '2013-07-20', time_type: :vacation) }
    let!(:team_vacation) { FactoryGirl.create(:absence, user: team_member, start_date: '2014-01-01', end_date: '2014-01-01', time_type: :vacation) }

    before do
      get '/api/absences'
    end

    it 'lists all personal absences' do
      json.should have(1).items
    end

    subject { json.first }

    its(['id']) { should eq(own_vacation.id) }

    its(['start_date']) { should eq('2013-07-19') }
    its(['end_date']) { should eq('2013-07-20') }

    its(['is_recurring']) { should be_false }
    its(['weekly_repeat_interval']) { should_not be_present }
    its(['first_start_date']) { should_not be_present }
    its(['first_end_date']) { should_not be_present }

    its(['daypart']) { should eq('whole_day') }

    its(['user_id']) { should eq(api_user.id) }
    its(['user']) { should_not be_present }

    its(['time_type_id']) { should eq(TEST_TIME_TYPES[:vacation].id) }
    its(['time_type']) { should_not be_present }
  end

  describe 'GET /api/absences/date/:date' do
    let!(:absence) { FactoryGirl.create(:absence, user: api_user, start_date: '2013-07-19', end_date: '2013-07-20', time_type: :vacation) }

    before do
      absence.recurring_schedule.update_attributes(active: true, ends: 'date', ends_date: '2013-12-31', weekly_repeat_interval: 1)

      get '/api/absences/date/2013-09-27'
    end

    it 'lists all absences for the given date' do
      json.should have(1).items
    end

    subject { json.first }

    its(['start_date']) { should eq('2013-09-27') }
    its(['end_date']) { should eq('2013-09-28') }

    its(['is_recurring']) { should be_true }
    its(['weekly_repeat_interval']) { should eq(1) }
    its(['first_start_date']) { should eq('2013-07-19') }
    its(['first_end_date']) { should eq('2013-07-20') }
  end

  describe 'GET /api/team_absences/date/:date' do
    let!(:team_member) { FactoryGirl.create(:user, teams: api_user.teams)}

    let!(:self_absence) { FactoryGirl.create(:absence, user: api_user, start_date: '2013-07-19', end_date: '2013-07-20', time_type: :vacation) }
    let!(:team_absence) { FactoryGirl.create(:absence, user: team_member, start_date: '2013-07-19', end_date: '2013-07-20', time_type: :vacation) }
    let!(:foreign_absence) { FactoryGirl.create(:absence, start_date: '2013-07-19', end_date: '2013-07-20', time_type: :vacation) }

    before do
      get '/api/team_absences/date/2013-07-20'
    end

    it 'lists all absences for the given date' do
      json.should have(1).items
    end

    subject { json.first }

    its(['id']) { should eq(team_absence.id) }
  end

end
