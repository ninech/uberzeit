require 'spec_helper'

describe 'Roles and Rights' do
  include RequestHelpers

  let(:user) { FactoryGirl.create(:user) }
  let(:another_user) { FactoryGirl.create(:user) }
  let(:year) { Date.current.year }
  let(:month) { Date.current.month }

  def should_have_access_to(path)
    expect { visit path }.to_not raise_error(CanCan::AccessDenied)
  end

  def should_not_have_access_to(path)
    expect { visit path }.to raise_error(CanCan::AccessDenied)
  end

  context 'role: user' do
    before do
      login(user)
    end

    describe 'time sheets' do
      it 'has access to own time sheet' do
        should_have_access_to time_sheet_path(user.current_time_sheet)
      end

      it 'has no access to another time sheet' do
        should_not_have_access_to time_sheet_path(another_user.current_time_sheet)
      end
    end

    describe 'absences' do
      it 'has access to own absences' do
        should_have_access_to time_sheet_absences_path(user.current_time_sheet)
      end

      it 'has no access to absences of other users' do
        should_not_have_access_to time_sheet_absences_path(another_user.current_time_sheet)
      end
    end

    describe 'summaries' do
      it 'has access to own summaries' do
        should_have_access_to user_summaries_work_year_path(user.current_time_sheet, year)
        should_have_access_to user_summaries_absence_year_path(user.current_time_sheet, year)
      end

      it 'has no access to absences of other users' do
        should_not_have_access_to user_summaries_work_year_path(another_user.current_time_sheet, year)
        should_not_have_access_to user_summaries_absence_year_path(another_user.current_time_sheet, year)
      end

      it 'has access to overall absence summary' do
        user && another_user
        visit calendar_summaries_absence_users_path(year, month)

        page.should have_selector('td', text: user.display_name)
        page.should have_selector('td', text: another_user.display_name)
      end

      it 'receives an empty view for overall work summary' do
        user && another_user
        visit year_summaries_work_users_path(year, month)

        page.should_not have_selector('td', text: user.display_name)
        page.should_not have_selector('td', text: another_user.display_name)
      end

      it 'receives an empty view for overall vacation summary' do
        user && another_user
        visit year_summaries_vacation_users_path(year, month)

        page.should_not have_selector('td', text: user.display_name)
        page.should_not have_selector('td', text: another_user.display_name)
      end
    end

    describe 'manage' do
      it 'has no acccess to public holidays' do
        should_not_have_access_to public_holidays_path
      end

      it 'has no acccess to users' do
        should_not_have_access_to users_path
      end

      it 'has no access to time types' do
        should_not_have_access_to time_types_path
      end
    end
  end

end
