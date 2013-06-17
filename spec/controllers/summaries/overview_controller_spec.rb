require 'spec_helper'

describe Summaries::OverviewController do

  let(:user) { FactoryGirl.create(:user, with_sheet: true) }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :index, user_id: user
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do

    before do
      test_sign_in user
    end

    describe 'GET "index"' do
      it 'assigns the correct instance variables' do
        get :index, user_id: user
        assigns(:uberzeit).should_not be_nil
        assigns(:month_total_work).should_not be_nil
        assigns(:month_percent_done).should_not be_nil
        assigns(:personal_absences).should_not be_nil
        assigns(:team_absences).should_not be_nil
        assigns(:vacation_redeemed).should_not be_nil
        assigns(:vacation_remaining).should_not be_nil
      end

      it 'renders the :index template' do
        get :index, user_id: user
        response.should render_template :index
      end

      describe 'team absences' do
        let!(:another_team) { FactoryGirl.create(:team) }
        let!(:another_user) { FactoryGirl.create(:user, teams: user.teams | [another_team]) }

        before do
          user.teams << another_team
          Timecop.freeze('2013-07-20 12:00:00')
        end

        it 'shows a team member only once even when she shares the same teams with the current user' do
          FactoryGirl.create(:absence, time_sheet: another_user.current_time_sheet, start_date: '2013-07-22', end_date: '2013-07-22')
          get :index, user_id: user
          assigns(:team_absences).should include('2013-07-22'.to_date)
          assigns(:team_absences)['2013-07-22'.to_date].should have(1).absences
        end

        it 'does not show the current user in the team absences' do
          FactoryGirl.create(:absence, time_sheet: user.current_time_sheet, start_date: '2013-07-22', end_date: '2013-07-22')
          get :index, user_id: user
          assigns(:team_absences).should_not include('2013-07-22'.to_date)
        end
      end

    end

  end

end
