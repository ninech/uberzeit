require 'spec_helper'

describe Reports::AbsenceController do
  render_views

  let(:user) { FactoryGirl.create(:user) }
  let(:year) { 2013 }
  let(:month) { 3 }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :show, year: year
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do

    before do
      test_sign_in user
    end

    describe 'GET "year"' do
      it 'assigns the correct instance variables' do
        get :show, year: year
        assigns(:year).should_not be_nil
        assigns(:result).should_not be_nil
        assigns(:total).should_not be_nil
      end

      it 'renders the :year template' do
        get :show, year: year
        response.should render_template :table
      end
    end

    describe 'GET "month"' do
      it 'assigns the correct instance variables' do
        get :show, year: year, month: month
        assigns(:year).should_not be_nil
        assigns(:month).should_not be_nil
        assigns(:result).should_not be_nil
        assigns(:total).should_not be_nil
      end

      it 'renders the :month template' do
        get :show, year: year, month: month
        response.should render_template :table
      end
    end

    describe 'GET "calendar"' do
      it 'assigns the correct instance variables' do
        get :calendar, year: year, month: month
        assigns(:year).should_not be_nil
        assigns(:month).should_not be_nil
        assigns(:absences_by_user_and_date).should_not be_nil
      end

      it 'renders the :calendar template' do
        get :calendar, year: year, month: month
        response.should render_template :calendar
      end

      describe 'special rights' do
        let!(:another_team) { FactoryGirl.create(:team) }
        let!(:another_user) { FactoryGirl.create(:user, teams: [another_team]) }

        it 'shows all users for all users' do
          get :calendar, year: year, month: month
          assigns(:users).should =~ [user, another_user]
        end

        it 'shows all teams for all users' do
          get :calendar, year: year, month: month
          assigns(:teams).should =~ user.teams + another_user.teams
        end

        it 'shows the requested team' do
          get :calendar, year: year, month: month, team_id: another_team.id
          assigns(:team).should eq(another_team)
          assigns(:users).should =~ [another_user]
        end
      end
    end

  end

end
