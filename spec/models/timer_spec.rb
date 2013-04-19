require 'spec_helper'

describe Timer do
  it 'has a valid factory' do
    FactoryGirl.build(:timer).should be_valid
  end

  it 'requires a start time' do
    FactoryGirl.build(:timer, start_time: nil).should_not be_valid
  end
end
