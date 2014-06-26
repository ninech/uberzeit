require 'spec_helper'

describe Reports::VacationController do
  render_views

  before(:all) do
    @team = FactoryGirl.create(:team)
    @another_team = FactoryGirl.create(:team, users_count: 1, leaders_count: 1)
    @team_leader = FactoryGirl.create(:team_leader, teams: [@team])
    @admin = FactoryGirl.create(:admin, teams: [@team])
    @user = FactoryGirl.create(:user, teams: [@team])
    @year = 2013

    [@team, @another_team].map(&:members).flatten.each do |user|
      Day.create_or_regenerate_days_for_user_and_year!(user, @year)
    end
  end

  after(:all) do
    Team.delete_all
    Membership.delete_all
    User.delete_all
    Day.delete_all
  end

  let(:team) { @team }
  let(:another_team) { @another_team }

  let(:team_leader) { @team_leader }
  let(:user) { @user }
  let(:admin) { @admin }
  let(:year) { @year }
  let(:month) { 3 }

  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

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

    context 'user has rights to view this report' do
      before do
        @ability.can :manage, :vacation
      end

      it 'allows to view this report when user has rights' do
        expect { get :show, year: year }.to_not raise_error
      end
    end

    context 'user has no rights to view this report' do
      before do
        @ability.cannot :manage, :vacation
      end

      it 'denies to view this report when user has rights' do
        expect { get :show, year: year }.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end
