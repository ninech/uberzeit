require 'spec_helper'

describe Employment do
  it 'has a valid factory' do
    FactoryGirl.create(:employment).should be_valid
  end
end
