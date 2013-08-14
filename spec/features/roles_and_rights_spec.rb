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

    describe 'timesheet' do
      let(:path) { time_sheet_path(user.current_time_sheet) }

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
      let(:path) { time_sheet_absences_path(user.current_time_sheet) }

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

    describe 'summaries' do
      describe 'my summary' do
        shared_examples :my_summary_access do
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

        describe 'my work summary' do
          let(:path) { user_summaries_work_year_path(user.current_time_sheet, year) }
          include_examples :my_summary_access
        end

        describe 'my absence summary' do
          let(:path) { user_summaries_absence_year_path(user.current_time_sheet, year) }
          include_examples :my_summary_access
        end
      end

      describe 'overall summary' do
        shared_examples :overall_summary_access do
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

        describe 'work summary' do
          describe 'monthly' do
            let(:path) { month_summaries_work_users_path(year, month) }
            include_examples :overall_summary_access
          end
          describe 'yearly' do
            let(:path) { year_summaries_work_users_path(year, month) }
            include_examples :overall_summary_access
          end
        end

        describe 'vacation summary' do
          describe 'monthly' do
            let(:path) { month_summaries_vacation_users_path(year, month) }
            include_examples :overall_summary_access
          end
          describe 'yearly' do
            let(:path) { year_summaries_vacation_users_path(year, month) }
            include_examples :overall_summary_access
          end
        end

        describe 'absences summary' do
          shared_examples :overall_absences_summary do
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
            let(:path) { month_summaries_vacation_users_path(year, month) }
            include_examples :overall_summary_access
          end

          describe 'yearly' do
            let(:path) { year_summaries_vacation_users_path(year, month) }
            include_examples :overall_summary_access
          end

          describe 'calendar' do
            let(:path) { year_summaries_vacation_users_path(year, month) }
            include_examples :overall_summary_access
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

    describe 'menu items' do
      before do
        visit user_summaries_work_year_path(current_user.current_time_sheet, year)
      end

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

      context 'as user' do
        let(:current_user) { user }

        describe 'main menu' do
          include_examples :menu_list, '.navigation > ul > li', ['Zeiterfassung', 'Absenzen', 'Berichte'], ['Verwalten']
        end

        describe 'summary menu' do
          include_examples :menu_list, '.sub-nav > dd', ['Meine Arbeitszeit', 'Meine Absenzen', 'Absenzen Mitarbeiter'], ['Arbeitszeit Mitarbeiter', 'Feriensaldo']
        end
      end

      context 'as team leader' do
        let(:current_user) { team_leader }

        describe 'main menu' do
          include_examples :menu_list, '.navigation > ul > li', ['Zeiterfassung', 'Absenzen', 'Berichte'], ['Verwalten']
        end

        describe 'summary menu' do
          include_examples :menu_list, '.sub-nav > dd', ['Meine Arbeitszeit', 'Meine Absenzen', 'Absenzen Mitarbeiter', 'Arbeitszeit Mitarbeiter', 'Feriensaldo'], []
        end
      end

      context 'as admin' do
        let(:current_user) { admin }

        describe 'main menu' do
          include_examples :menu_list, '.navigation > ul > li', ['Zeiterfassung', 'Absenzen', 'Berichte', 'Verwalten'], []
        end

        describe 'summary menu' do
          include_examples :menu_list, '.sub-nav > dd', ['Meine Arbeitszeit', 'Meine Absenzen', 'Absenzen Mitarbeiter', 'Arbeitszeit Mitarbeiter', 'Feriensaldo'], []
        end
      end
    end

    describe 'absence overview' do
      before do
        visit time_sheet_absences_path(current_user.current_time_sheet)
      end

      let(:add_absence_selector) { "*[data-reveal-url^='#{new_time_sheet_absence_path(current_user.current_time_sheet)}']" }

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
        visit time_sheet_path(current_user.current_time_sheet)
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
