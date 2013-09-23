require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the AbsencesHelper. For example:
#
# describe AbsencesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe AbsencesHelper do

  describe '#render_calendar_cell' do
    before do
      @absences = {}
      @public_holidays = {}
    end

    let(:date) { Date.civil(2013, 1, 1) }
    let(:recurring_schedule) do
      mock.tap do |m|
        m.stub(:active?).and_return(false)
      end
    end
    let(:absence) do
       mock.tap do |m|
        m.stub(:id).and_return(42)
        m.stub(:starts).and_return('2013-01-01'.to_date)
        m.stub(:ends).and_return('2013-02-02'.to_date)
        m.stub(:range).and_return('2013-01-01'.to_date..'2013-02-02'.to_date)
        m.stub(:first_half_day?).and_return(false)
        m.stub(:second_half_day?).and_return(false)
        m.stub(:whole_day?).and_return(true)
        m.stub(:time_type).and_return(TEST_TIME_TYPES[:vacation])
        m.stub(:recurring_schedule).and_return(recurring_schedule)
        m.stub(:recurring?).and_return(false)
       end
     end

    let(:time_chunk) do
      TimeChunk.new(range: '2013-01-01'.to_date...'2013-02-02'.to_date, parent: absence)
    end

    it 'renders a calendar cell without a date' do
      assign(:user, user)
      helper.render_calendar_cell(date).first.to_s.should eq("1")
    end

    it 'renders a calendar cell with a date' do
      @time_types = TimeType.absence
      @absences[date] = [time_chunk]
      helper.render_calendar_cell(date).to_s.should =~ /event-bg#{TEST_TIME_TYPES.key(:vacation)}/
    end
  end

  describe '#other_team_members' do
    let!(:team) { FactoryGirl.create(:team) }
    let!(:user) { FactoryGirl.create(:user, teams: [team]) }
    let!(:another_team) { FactoryGirl.create(:team) }
    let!(:another_user) { FactoryGirl.create(:user, teams: [another_team, team]) }

    it 'finds other members of the same teams' do
      other_team_members(user).should eq([another_user])
    end

    it 'will not return own user' do
      other_team_members(user).should_not include(user)
    end
  end
end
