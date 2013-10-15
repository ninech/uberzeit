require 'spec_helper'

describe API::App::Resources::Absences do
  include RequestHelpers

  let(:user) { FactoryGirl.create(:user) }
  let(:team) { user.teams.first }
  let(:json) { JSON.parse(response.body) }

  describe 'GET /api/app/absences/:id' do
    let!(:absence) { FactoryGirl.create(:absence) }

    before do
      app_auth_get "/api/app/absences/#{absence.id}"
    end

    subject { json }

    its(['id']) { should eq(absence.id) }
  end

  describe 'GET /api/absences/team/:team_id/date/:date' do
    let!(:absence) { FactoryGirl.create(:absence, user: user, start_date: '2013-07-19', end_date: '2013-07-20', time_type: :vacation, schedule_attributes: {active: true, ends_date: '2013-12-31', weekly_repeat_interval: 1}) }
    let!(:another_absence) { FactoryGirl.create(:absence, start_date: '2013-09-27') }

    before do
      app_auth_get "/api/app/absences/team/#{team.id}/date/2013-09-27"
    end

    it 'lists all team absences for the given date' do
      json.should have(1).items
    end

    subject { json.first }
    its(['id']) { should eq(absence.id) }
  end

end
