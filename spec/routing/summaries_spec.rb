require 'spec_helper'

describe 'routing of the summaries' do


  context 'user specific' do

    describe 'overview' do
      it 'routes /users/:id/summaries/overview to overview#index' do
        expect(get: '/users/1/summaries/overview').to route_to(
          controller: 'summaries/overview',
          action: 'index',
          user_id: '1',
        )
      end
    end

    describe 'work' do
      it 'routes /users/:id/summaries/work/:year to my_work#year' do
        expect(get: '/users/1/summaries/work/2013').to route_to(
          controller: 'summaries/work/my_work',
          action: 'year',
          user_id: '1',
          year: '2013',
        )
      end

      it 'routes /users/:id/summaries/work/:year/:month to my_work#month' do
        expect(get: '/users/1/summaries/work/2013/8').to route_to(
          controller: 'summaries/work/my_work',
          action: 'month',
          user_id: '1',
          year: '2013',
          month: '8',
        )
      end
    end

    describe 'absence' do
      it 'routes /users/:id/summaries/absence/:year to my_absence#year' do
        expect(get: '/users/1/summaries/absence/2013').to route_to(
          controller: 'summaries/absence/my_absence',
          action: 'year',
          user_id: '1',
          year: '2013',
        )
      end

      it 'routes /users/:id/summaries/absence/:year/:month to my_absence#month' do
        expect(get: '/users/1/summaries/absence/2013/8').to route_to(
          controller: 'summaries/absence/my_absence',
          action: 'month',
          user_id: '1',
          year: '2013',
          month: '8',
        )
      end
    end
  end

  context 'user list' do

    describe 'work' do
      it 'routes /users/summaries/work/2013 to work#year' do
        expect(get: '/users/summaries/work/2013').to route_to(
          controller: 'summaries/work/work',
          action: 'year',
          year: '2013',
        )
      end

      it 'routes /users/summaries/work/2013/team/1 to work#year' do
        expect(get: '/users/summaries/work/2013/team/1').to route_to(
          controller: 'summaries/work/work',
          action: 'year',
          year: '2013',
          team_id: '1',
        )
      end

      it 'routes /users/summaries/work/2013/8 to work#month' do
        expect(get: '/users/summaries/work/2013/8').to route_to(
          controller: 'summaries/work/work',
          action: 'month',
          year: '2013',
          month: '8',
        )
      end

      it 'routes /users/summaries/work/2013/8/team/1 to work#month' do
        expect(get: '/users/summaries/work/2013/8/team/1').to route_to(
          controller: 'summaries/work/work',
          action: 'month',
          year: '2013',
          month: '8',
          team_id: '1',
        )
      end
    end

    describe 'absence' do

      it 'routes /users/summaries/absence/2013 to absence#year' do
        expect(get: '/users/summaries/absence/2013').to route_to(
          controller: 'summaries/absence/absence',
          action: 'year',
          year: '2013',
        )
      end

      it 'routes /users/summaries/absence/2013/team/1 to absence#year' do
        expect(get: '/users/summaries/absence/2013/team/1').to route_to(
          controller: 'summaries/absence/absence',
          action: 'year',
          year: '2013',
          team_id: '1',
        )
      end

      it 'routes /users/summaries/absence/2013/8 to absence#month' do
        expect(get: '/users/summaries/absence/2013/8').to route_to(
          controller: 'summaries/absence/absence',
          action: 'month',
          year: '2013',
          month: '8',
        )
      end

      it 'routes /users/summaries/absence/2013/8/team/1 to absence#month' do
        expect(get: '/users/summaries/absence/2013/8/team/1').to route_to(
          controller: 'summaries/absence/absence',
          action: 'month',
          year: '2013',
          month: '8',
          team_id: '1',
        )
      end

      it 'routes /users/summaries/absence/2013/8/as/calendar to absence#calendar' do
        expect(get: '/users/summaries/absence/2013/8/as/calendar').to route_to(
          controller: 'summaries/absence/absence',
          action: 'calendar',
          year: '2013',
          month: '8',
        )
      end

    end

    describe 'vacation' do
      it 'routes /users/summaries/vacation/2013 to vacation#year' do
        expect(get: '/users/summaries/vacation/2013').to route_to(
          controller: 'summaries/vacation/vacation',
          action: 'year',
          year: '2013',
        )
      end

      it 'routes /users/summaries/vacation/2013/team/1 to vacation#year' do
        expect(get: '/users/summaries/vacation/2013/team/1').to route_to(
          controller: 'summaries/vacation/vacation',
          action: 'year',
          year: '2013',
          team_id: '1',
        )
      end

      it 'routes /users/summaries/vacation/2013/8 to vacation#month' do
        expect(get: '/users/summaries/vacation/2013/8').to route_to(
          controller: 'summaries/vacation/vacation',
          action: 'month',
          year: '2013',
          month: '8',
        )
      end

      it 'routes /users/summaries/vacation/2013/8/team/1 to vacation#month' do
        expect(get: '/users/summaries/vacation/2013/8/team/1').to route_to(
          controller: 'summaries/vacation/vacation',
          action: 'month',
          year: '2013',
          month: '8',
          team_id: '1',
        )
      end
    end

  end
end
