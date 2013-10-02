require 'spec_helper'

describe Summaries::Work::WorkController do
  render_views

  before(:all) do
    @team = FactoryGirl.create(:team, users_count: 1, leaders_count: 1)
    @another_team = FactoryGirl.create(:team, users_count: 1, leaders_count: 1)
    @admin = FactoryGirl.create(:admin, teams: [@team])
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

  let(:user) { team.members.first }
  let(:team_leader) { team.leaders.first }
  let(:admin) { @admin }
  let(:year) { @year }
  let(:month) { 3 }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :year, year: year
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do

    before do
      test_sign_in user
    end

    describe 'GET "year"' do
      it 'denies access' do
        expect { get :year, year: year }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe 'GET "month"' do
      it 'denies access' do
        expect { get :month, year: year, month: month }.to raise_error(CanCan::AccessDenied)
      end
    end

  end

  context 'for signed-in admins' do

    before do
      test_sign_in admin
    end

    describe 'GET "year"' do
      context 'rights and roles' do
        it 'returns rows for all users' do
          get :year, year: year
          assigns(:table).entries.count.should eq(team.members.count + another_team.members.count)
        end

        it 'returns rows for a specified team' do
          get :year, year: year, team_id: team.id
          assigns(:table).entries.count.should eq(team.members.count)
        end
      end
    end

    describe 'GET "month"' do
      context 'rights and roles' do
        it 'returns rows for all users' do
          get :year, year: year, month: month
          assigns(:table).entries.count.should eq(team.members.count + another_team.members.count)
        end

        it 'returns rows for a specified team' do
          get :year, year: year, month: month, team_id: team.id
          assigns(:table).entries.count.should eq(team.members.count)
        end
      end
    end

  end

  context 'for signed-in team leaders' do

    before do
      test_sign_in team_leader
    end

    describe 'GET "year"' do
      context 'rights and roles' do
        it 'returns rows for users of his teams' do
          get :year, year: year
          assigns(:table).entries.count.should eq(team.members.count)
        end

        it 'returns rows for a managed team' do
          get :year, year: year, team_id: team.id
          assigns(:table).entries.count.should eq(team.members.count)
        end

        it 'returns not the rows for a non-managed team' do
          get :year, year: year, team_id: another_team.id
          assigns(:table).entries.any?{ |user, entry| another_team.members.include?(user) }.should be_false
        end

      end
    end

    describe 'GET "month"' do
      context 'rights and roles' do
        it 'returns rows for all users' do
          get :year, year: year, month: month
          assigns(:table).entries.count.should eq(team.members.count)
        end

        it 'returns rows for a specified team' do
          get :year, year: year, month: month, team_id: team.id
          assigns(:table).entries.count.should eq(team.members.count)
        end
      end
    end

  end

      # end
end
