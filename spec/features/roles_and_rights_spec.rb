# encoding: utf-8

require 'spec_helper'

describe 'Roles and Rights' do
  include RequestHelpers

  let(:year) { Date.current.year }
  let(:month) { Date.current.month }

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:team_leader) { FactoryGirl.create(:team_leader, teams: user.teams) }
  let(:admin) { FactoryGirl.create(:admin) }

  before do
    login current_user
  end

  describe 'access' do
    shared_examples :access_granted do
      it 'allows access' do
        visit path
        page.status_code.should == 200
      end
    end

    shared_examples :access_denied do
      it 'denies access' do
        expect { visit path }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe 'time entries' do
      let(:path) { user_time_entries_path(user) }

      context 'as owner' do
        let(:current_user) { user }
        include_examples :access_granted
      end

      context 'as another user' do
        let(:current_user) { other_user }
        include_examples :access_denied
      end

      context 'as team leader of owner' do
        let(:current_user) { team_leader }
        include_examples :access_granted
      end

      context 'as admin' do
        let(:current_user) { admin }
        include_examples :access_granted
      end
    end

    describe 'activities' do
      let(:path) { user_activities_path(user) }

      context 'as owner' do
        let(:current_user) { user }
        include_examples :access_granted
      end

      context 'as another user' do
        let(:current_user) { other_user }
        include_examples :access_denied
      end

      context 'as team leader of owner' do
        let(:current_user) { team_leader }
        include_examples :access_granted
      end

      context 'as admin' do
        let(:current_user) { admin }
        include_examples :access_granted
      end
    end

    describe 'absences' do
      let(:path) { user_absences_path(user) }

      context 'as owner' do
        let(:current_user) { user }
        include_examples :access_granted
      end

      context 'as another user' do
        let(:current_user) { other_user }
        include_examples :access_denied
      end

      context 'as team leader of user' do
        let(:current_user) { team_leader }
        include_examples :access_granted
      end

      context 'as admin' do
        let(:current_user) { admin }
        include_examples :access_granted
      end
    end

    describe 'reports' do
      describe 'my reports' do
        shared_examples :my_reports_access do
          context 'as user' do
            let(:current_user) { user }
            include_examples :access_granted
          end

          context 'as team leader' do
            let(:current_user) { team_leader }
            include_examples :access_granted
          end

          context 'as admin' do
            let(:current_user) { admin }
            include_examples :access_granted
          end
        end

        describe 'my work report' do
          let(:path) { reports_my_work_path(user, year: year) }
          include_examples :my_reports_access
        end
      end

      describe 'overall reports' do
        shared_examples :overall_reports_access do
          context 'as user' do
            let(:current_user) { user }
            include_examples :access_denied
          end

          context 'as team leader' do
            let(:current_user) { team_leader }
            include_examples :access_granted
          end

          context 'as admin' do
            let(:current_user) { admin }
            include_examples :access_granted
          end
        end

        describe 'work report' do
          describe 'monthly' do
            let(:path) { reports_work_path(year: year, month: month) }
            include_examples :overall_reports_access
          end
          describe 'yearly' do
            let(:path) { reports_work_path(year: year) }
            include_examples :overall_reports_access
          end
        end

        describe 'vacation report' do
          describe 'monthly' do
            let(:path) { reports_vacation_path(year: year, month: month) }
            include_examples :overall_reports_access
          end
          describe 'yearly' do
            let(:path) { reports_vacation_path(year: year) }
            include_examples :overall_reports_access
          end
        end

        describe 'absences report' do
          shared_examples :overall_absences_report do
            context 'as user' do
              let(:current_user) { user }
              include_examples :access_granted
            end

            context 'as team leader' do
              let(:current_user) { team_leader }
              include_examples :access_granted
            end

            context 'as admin' do
              let(:current_user) { admin }
              include_examples :access_granted
            end
          end

          describe 'monthly' do
            let(:path) { reports_absences_path(year: year, month: month) }
            include_examples :overall_absences_report
          end

          describe 'yearly' do
            let(:path) { reports_absences_path(year: year) }
            include_examples :overall_absences_report
          end

          describe 'calendar' do
            let(:path) { reports_absences_calendar_path(year: year, month: month) }
            include_examples :overall_absences_report
          end
        end
      end
    end

    describe 'manage' do
      shared_examples :manage_access do
        context 'as user' do
          let(:current_user) { user }
          include_examples :access_denied
        end

        context 'as team leader' do
          let(:current_user) { team_leader }
          include_examples :access_denied
        end

        context 'as admin' do
          let(:current_user) { admin }
          include_examples :access_granted
        end
      end

      describe 'public holidays' do
        let(:path) { public_holidays_path }
        include_examples :manage_access
      end

      describe 'users' do
        let(:path) { users_path }
        include_examples :manage_access
      end

      describe 'time types' do
        let(:path) { time_types_path }
        include_examples :manage_access
      end

      describe 'adjustments' do
        let(:path) { adjustments_path }
        include_examples :manage_access
      end
    end
  end

  describe 'interface' do
    subject { page }

    shared_examples :menu_list do |selector, included, excluded|
      included.each do |included_item|
        it "should include #{included_item}" do
          subject.should have_selector(selector, text: included_item)
        end
      end

      excluded.each do |excluded_item|
        it "should exclude #{excluded_item}" do
          subject.should_not have_selector(selector, text: excluded_item)
        end
      end
    end

    describe 'reports' do
      before do
        visit reports_my_work_path(current_user, year: year)
      end

      context 'as user' do
        let(:current_user) { user }

        describe 'main menu' do
          include_examples :menu_list, 'section > ul > li', ['Zeiterfassung', 'Absenzen', 'Berichte'], ['Verwalten']
        end

        describe 'report menu' do
          include_examples :menu_list, '.sub-nav > li', ['Meine Arbeitszeit'], ['Arbeitszeit Mitarbeiter', 'Feriensaldo']
        end
      end

      context 'as team leader' do
        let(:current_user) { team_leader }

        describe 'main menu' do
          include_examples :menu_list, 'section > ul > li', ['Zeiterfassung', 'Absenzen', 'Aktivitäten', 'Berichte', 'Verwalten'], []
        end

        describe 'report menu' do
          include_examples :menu_list, '.sub-nav > li', ['Meine Arbeitszeit', 'Arbeitszeit Mitarbeiter'], []
        end
      end

      context 'as admin' do
        let(:current_user) { admin }

        describe 'main menu' do
          include_examples :menu_list, 'section > ul > li', ['Zeiterfassung', 'Absenzen', 'Aktivitäten', 'Berichte', 'Verwalten'], []
        end

        describe 'report menu' do
          include_examples :menu_list, '.sub-nav > li', ['Meine Arbeitszeit', 'Arbeitszeit Mitarbeiter', 'Feriensaldo'], []
        end
      end
    end

    describe 'activities' do
      before do
        visit reports_activities_billability_path
      end

      context 'as accountant' do
        let(:accountant) { FactoryGirl.create(:accountant) }
        let(:current_user) { accountant }

        describe 'activities menu' do
          include_examples :menu_list, '.sub-nav > li', ['Verrechenbarkeit', 'Verrechnung'], []
        end
      end

      context 'as team leader' do
        let(:current_user) { team_leader }

        describe 'activities menu' do
          include_examples :menu_list, '.sub-nav > li', ['Übersicht', 'Verrechenbarkeit'], []
        end
      end

      context 'as admin' do
        let(:current_user) { admin }

        describe 'activities menu' do
          include_examples :menu_list, '.sub-nav > li', ['Übersicht', 'Verrechenbarkeit', 'Verrechnung'], []
        end
      end
    end

    describe 'absence overview' do
      before do
        visit user_absences_path(current_user)
      end

      let(:add_absence_selector) { "*[data-reveal-url^='#{new_user_absence_path(current_user)}']" }

      context 'as user' do
        let(:current_user) { user }
        it { should_not have_selector(add_absence_selector) }
      end

      context 'as team leader' do
        let(:current_user) { team_leader }
        it { should have_selector(add_absence_selector) }
      end

      context 'as admin' do
        let(:current_user) { admin }
        it { should have_selector(add_absence_selector) }
      end
    end

    describe 'select box to select another user' do
      before do
        visit user_time_entries_path(current_user)
      end

      context 'as user' do
        let(:current_user) { user }
        it { should_not have_selector("select[name='user']") }
      end

      context 'as team leader' do
        let(:current_user) { team_leader }
        it { should have_selector("select[name='user']") }
      end

      context 'as admin' do
        let(:current_user) { admin }
        it { should have_selector("select[name='user']") }
      end
    end
  end
end
