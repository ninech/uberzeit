require 'spec_helper'

describe TimeSheet do
  it 'has a valid factory' do
    FactoryGirl.create(:time_sheet).should be_valid
  end
end