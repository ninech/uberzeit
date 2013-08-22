require 'spec_helper'

describe FindAbsences do
  let(:from) { '2013-07-20'.to_date }
  let(:to) { '2013-07-21'.to_date }

  let(:range) { from..to }

  let!(:user) { FactoryGirl.create(:user, teams: [team]) }
  let!(:team) { FactoryGirl.create(:team) }

  let(:find_absences) { FindAbsences.new(user, range) }

  let!(:foreign_absence) { FactoryGirl.create(:absence, start_date: '2013-07-16', end_date: '2013-07-20') }

  describe 'personal absences' do
    let!(:absence) { FactoryGirl.create(:absence, time_sheet: user.current_time_sheet, start_date: '2013-07-16', end_date: '2013-07-20') }

    it 'lists the personal absences per date' do
      find_absences.personal_absences[from].should have(1).chunks
      find_absences.personal_absences[from].first.id.should eq(absence.id)
    end
  end

  describe 'team absences' do
    let!(:another_team) { FactoryGirl.create(:team) }
    let!(:another_user) { FactoryGirl.create(:user, teams: [another_team, team]) }
    let!(:another_absence) { FactoryGirl.create(:absence, time_sheet: another_user.current_time_sheet, start_date: '2013-07-16', end_date: '2013-07-20') }

    it 'lists absences of a team member only once even when she shares the same teams with the current user' do
      find_absences.team_absences[from].should have(1).chunks
      find_absences.team_absences[from].first.id.should eq(another_absence.id)
    end
  end

end
