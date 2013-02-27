require 'spec_helper'

describe Employment do
  it 'has a valid factory' do
    FactoryGirl.create(:employment).should be_valid
  end

  it 'cannot be deleted if it is the last one' do
    pending
  end

  it 'has a workload within the range of 0 to 100' do

  end

  
end
