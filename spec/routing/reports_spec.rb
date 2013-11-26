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
      it 'routes /reports/work/users/:id to my_work#year' do
        expect(get: '/reports/work/users/1').to route_to(
          controller: 'reports/my_work',
          action: 'show',
          user_id: '1',
        )
      end
    end
  end

  context 'user list' do

    describe 'work' do
      it 'routes /reports/work to work#show' do
        expect(get: '/reports/work').to route_to(
          controller: 'reports/work',
          action: 'show',
        )
      end
    end

    describe 'absence' do

      it 'routes /reports/absences to absence#show' do
        expect(get: '/reports/absences').to route_to(
          controller: 'reports/absence',
          action: 'show',
        )
      end

      it 'routes /reports/absences-calendar to absence#calendar' do
        expect(get: '/reports/absences-calendar').to route_to(
          controller: 'reports/absence',
          action: 'calendar',
        )
      end
    end

    describe 'vacation' do

      it 'routes /reports/vacation to vacation#show' do
        expect(get: '/reports/vacation').to route_to(
          controller: 'reports/vacation',
          action: 'show',
        )
      end
    end

  end
end
