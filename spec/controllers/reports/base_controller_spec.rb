require 'spec_helper'

describe Reports::BaseController do
  controller(Reports::BaseController) do
    def index
      render nothing: true
    end
  end

  let!(:user) { FactoryGirl.create(:admin) }
  let!(:another_user) { FactoryGirl.create(:user, teams: user.teams) }
  let!(:another_user_in_another_team) { FactoryGirl.create(:user) }

  before do
    test_sign_in user
  end

  it '@month' do
    get :index, month: 7
    assigns(:month).should eq(7)
  end

  it '@month_as_date' do
    get :index, month: 7, year: 2013
    assigns(:month_as_date).should eq('2013-07-01'.to_date)
  end

  it '@year' do
    get :index, year: 2052
    assigns(:year).should eq(2052)
  end

  describe '@users' do
    context 'user specified' do
      it 'sets only the requested user' do
        get :index, user_id: user.id
        assigns(:users).should =~ [user]
      end
    end

    context 'teams specified' do
      it 'sets only the requested teams' do
        get :index, team_ids: [user.teams.first.id]
        assigns(:users).should =~ [user, another_user]
      end
    end

    context 'nothing specified' do
      it 'sets all the accessible users' do
        get :index
        assigns(:users).should =~ [user, another_user, another_user_in_another_team]
      end
    end

    describe 'deactivated user handling' do
      let!(:deactivated_user) { FactoryGirl.create(:user, active: false) }
      it 'does not include deactivated users' do
        get :index
        assigns(:users).should_not include(deactivated_user)
      end
    end
  end

  describe '@teams' do
    it 'sets the teams' do
      get :index
      assigns(:teams).should =~ (user.teams + another_user_in_another_team.teams)
    end
  end

  describe '@requested_teams' do
    it 'sets the requested teams' do
      get :index, team_ids: [user.teams.first.id]
      assigns(:requested_teams).should eq [user.teams.first]
    end
  end

end
