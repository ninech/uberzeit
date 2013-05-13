require 'spec_helper'

describe Summaries::Vacation::VacationController do
  render_views

  before do
    @team = FactoryGirl.create(:team, users_count: 3, leaders_count: 1)
    @another_team = FactoryGirl.create(:team, users_count: 7, leaders_count: 2)
  end

  let(:user) { @team.members.first }
  let(:team_leader) { @team.leaders.first }
  let(:admin) { FactoryGirl.create(:admin, teams: [@team]) }
  let(:year) { 2013 }
  let(:month) { 3 }

  context 'for non-signed in users' do
    it 'denies access' do
      expect { get :year, year: year }.to raise_error(CanCan::AccessDenied)
    end
  end

  context 'for signed-in users' do

    before do
      test_sign_in user
    end

    describe 'GET "year"' do
      it 'assigns the correct instance variables' do
        get :year, year: year
        assigns(:year).should_not be_nil
        assigns(:table).should_not be_nil
      end

      it 'renders the :year template' do
        get :year, year: year
        response.should render_template :year
      end

      context 'rights and roles' do
        it 'returns no rows for a simple user' do
          get :year, year: year
          assigns(:table).entries.should be_empty

          get :year, year: year, team: @team.id
          assigns(:table).entries.should be_empty
        end
      end

    end

    describe 'GET "month"' do
      it 'assigns the correct instance variables' do
        get :month, year: year, month: month
        assigns(:year).should_not be_nil
        assigns(:month).should_not be_nil
        assigns(:table).should_not be_nil
      end

      it 'renders the :month template' do
        get :month, year: year, month: month
        response.should render_template :month
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
          assigns(:table).entries.count.should eq(@team.members.count + @another_team.members.count)
        end

        it 'returns rows for a specified team' do
          get :year, year: year, team_id: @team.id
          assigns(:table).entries.count.should eq(@team.members.count)
        end
      end
    end

    describe 'GET "month"' do
      context 'rights and roles' do
        it 'returns rows for all users' do
          get :year, year: year, month: month
          assigns(:table).entries.count.should eq(@team.members.count + @another_team.members.count)
        end

        it 'returns rows for a specified team' do
          get :year, year: year, month: month, team_id: @team.id
          assigns(:table).entries.count.should eq(@team.members.count)
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
          assigns(:table).entries.count.should eq(@team.members.count)
        end

        it 'returns rows for a managed team' do
          get :year, year: year, team_id: @team.id
          assigns(:table).entries.count.should eq(@team.members.count)
        end

        it 'returns not the rows for a non-managed team' do
          get :year, year: year, team_id: @another_team.id
          assigns(:table).entries.any?{ |user, entry| @another_team.members.include?(user) }.should be_false
        end

      end
    end

    describe 'GET "month"' do
      context 'rights and roles' do
        it 'returns rows for all users' do
          get :year, year: year, month: month
          assigns(:table).entries.count.should eq(@team.members.count)
        end

        it 'returns rows for a specified team' do
          get :year, year: year, month: month, team_id: @team.id
          assigns(:table).entries.count.should eq(@team.members.count)
        end
      end
    end

  end

end
