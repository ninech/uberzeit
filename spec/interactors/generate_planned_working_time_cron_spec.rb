require 'spec_helper'
require 'rake'

describe GeneratePlannedWorkingTimeCron do

  it 'runs the correct commands' do
    user = FactoryGirl.create(:user)
    year = Time.now.year
    Day.should respond_to(:create_or_regenerate_days_for_user_and_year!)
    Day.should_receive(:create_or_regenerate_days_for_user_and_year!).once.with(user, year)
    Day.should_receive(:create_or_regenerate_days_for_user_and_year!).once.with(user, year + 1)
    GeneratePlannedWorkingTimeCron.new.run
  end

end
