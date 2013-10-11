# == Schema Information
#
# Table name: days
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  date                 :date
#  planned_working_time :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'spec_helper'

describe Day do

  let(:user) { FactoryGirl.create(:user) }
  let(:year) { 2013 }

  describe '.create_or_regenerate_days_for_user_and_year' do

    let(:date) { Date.civil(year, 1, 1)..Date.civil(year, 12, 31) }

    it 'uses GeneratePlannedWorkingTimesForUserAndYear to generate all the entries' do
      calculator = mock.tap { |m| m.should_receive(:run) }
      GeneratePlannedWorkingTimeForUserAndDates.should_receive(:new).with(user, date).and_return(calculator)
      Day.create_or_regenerate_days_for_user_and_year!(user, year)
    end

  end


  describe '#regenerate' do

    let(:date) { Date.civil(year, 12, 24) }

    subject { Day.find_by_date(date) }

    before do
      Day.create_or_regenerate_days_for_user_and_year!(user, year)
    end

    it 'uses GeneratePlannedWorkingTimeForUserAndDate to generate all the entries' do
      calculator = mock.tap { |m| m.should_receive(:run) }
      GeneratePlannedWorkingTimeForUserAndDates.should_receive(:new).with(user, date).and_return(calculator)
      subject.regenerate!
    end

  end
end
