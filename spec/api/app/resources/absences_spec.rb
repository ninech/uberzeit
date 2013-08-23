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
    let!(:absence) { FactoryGirl.create(:absence, time_sheet: user.current_time_sheet, start_date: '2013-07-19', end_date: '2013-07-20', time_type: :vacation) }

    before do
      absence.recurring_schedule.update_attributes(active: true, ends: 'date', ends_date: '2013-12-31', weekly_repeat_interval: 1)

      app_auth_get "/api/app/absences/team/#{team.id}/date/2013-09-27"
    end

    it 'lists all absences for the given date' do
      json.should have(1).items
    end

    subject { json.first }

    its(['start_date']) { should eq('2013-09-27') }
    its(['end_date']) { should eq('2013-09-28') }

    its(['is_recurring']) { should be_true }
  end

end
