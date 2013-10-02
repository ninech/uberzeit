require 'spec_helper'

describe 'routing of the summaries' do


  context 'user specific' do

    describe 'overview' do
      it 'routes /reports/overview/users/:id to overview#index' do
        expect(get: '/reports/overview/users/1').to route_to(
          controller: 'reports/overview',
          action: 'index',
          user_id: '1',
        )
      end
    end

    describe 'work' do
      it 'routes /reports/work/users/:id/:year to my_work#year' do
        expect(get: '/reports/work/users/1/2013').to route_to(
          controller: 'reports/work/my_work',
          action: 'year',
          user_id: '1',
          year: '2013',
        )
      end

      it 'routes /reports/work/users/:id/:year/:month to my_work#month' do
        expect(get: '/reports/work/users/1/2013/8').to route_to(
          controller: 'reports/work/my_work',
          action: 'month',
          user_id: '1',
          year: '2013',
          month: '8',
        )
      end
    end

    describe 'absence' do
      it 'routes /reports/absences/users/:id/:year to my_absence#year' do
        expect(get: '/reports/absences/users/1/2013').to route_to(
          controller: 'reports/absences/my_absence',
          action: 'year',
          user_id: '1',
          year: '2013',
        )
      end

      it 'routes /reports/absences/users/:id/:year/:month to my_absence#month' do
        expect(get: '/reports/absences/users/1/2013/8').to route_to(
          controller: 'reports/absences/my_absence',
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
      it 'routes /reports/work/:year to work#year' do
        expect(get: '/reports/work/2013').to route_to(
          controller: 'reports/work/work',
          action: 'year',
          year: '2013',
        )
      end

      it 'routes /reports/work/:year/team/:id to work#year' do
        expect(get: '/reports/work/2013/team/1').to route_to(
          controller: 'reports/work/work',
          action: 'year',
          year: '2013',
          team_id: '1',
        )
      end

      it 'routes /reports/work/:year/:month to work#month' do
        expect(get: '/reports/work/2013/8').to route_to(
          controller: 'reports/work/work',
          action: 'month',
          year: '2013',
          month: '8',
        )
      end

      it 'routes /reports/work/:year/:month/team/:id to work#month' do
        expect(get: '/reports/work/2013/8/team/1').to route_to(
          controller: 'reports/work/work',
          action: 'month',
          year: '2013',
          month: '8',
          team_id: '1',
        )
      end
    end

    describe 'absence' do

      it 'routes /reports/absences/:year to absence#year' do
        expect(get: '/reports/absences/2013').to route_to(
          controller: 'reports/absences/absence',
          action: 'year',
          year: '2013',
        )
      end

      it 'routes /reports/absences/:year/team/:id to absence#year' do
        expect(get: '/reports/absences/2013/team/1').to route_to(
          controller: 'reports/absences/absence',
          action: 'year',
          year: '2013',
          team_id: '1',
        )
      end

      it 'routes /reports/absences/:year/:month to absence#month' do
        expect(get: '/reports/absences/2013/8').to route_to(
          controller: 'reports/absences/absence',
          action: 'month',
          year: '2013',
          month: '8',
        )
      end

      it 'routes /reports/absences/:year/:month/team/1 to absence#month' do
        expect(get: '/reports/absences/2013/8/team/1').to route_to(
          controller: 'reports/absences/absence',
          action: 'month',
          year: '2013',
          month: '8',
          team_id: '1',
        )
      end

      it 'routes /reports/absences/:year/:month/as/calendar to absence#calendar' do
        expect(get: '/reports/absences/2013/8/as/calendar').to route_to(
          controller: 'reports/absences/absence',
          action: 'calendar',
          year: '2013',
          month: '8',
        )
      end

      it 'does not route /reports/absences/calendar' do
        expect(get: '/reports/absences/calendar').not_to be_routable
      end
    end

    describe 'vacation' do

      it 'routes /reports/vacation/:year to vacation#year' do
        expect(get: '/reports/vacation/2013').to route_to(
          controller: 'reports/vacation/vacation',
          action: 'year',
          year: '2013',
        )
      end

      it 'routes /reports/vacation/:year/team/:id to vacation#year' do
        expect(get: '/reports/vacation/2013/team/1').to route_to(
          controller: 'reports/vacation/vacation',
          action: 'year',
          year: '2013',
          team_id: '1',
        )
      end

      it 'routes /reports/vacation/:year/:month to vacation#month' do
        expect(get: '/reports/vacation/2013/8').to route_to(
          controller: 'reports/vacation/vacation',
          action: 'month',
          year: '2013',
          month: '8',
        )
      end

      it 'routes /reports/vacation/:year/:month/team/:id to vacation#month' do
        expect(get: '/reports/vacation/2013/8/team/1').to route_to(
          controller: 'reports/vacation/vacation',
          action: 'month',
          year: '2013',
          month: '8',
          team_id: '1',
        )
      end
    end

  end
end
