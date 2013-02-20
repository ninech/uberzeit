require 'spec_helper'

describe Team do
  it 'has a valid factory' do
    FactoryGirl.create(:team).should be_valid
  end
end