require 'spec_helper'

describe SingleEntry do
  it 'has a valid factory' do
    FactoryGirl.create(:single_entry).should be_valid
  end 


end
