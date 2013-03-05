require 'spec_helper'

describe AfterLoginHelper do

  let(:user) { FactoryGirl.create(:user) }

  before do
    helper.sign_in(user)
  end

  it 'creates a timesheet for the current user when non-existent' do
    user.sheets.should_not be_empty
  end

  it 'creates an employment for the current user when non-existent' do
    user.employments.should_not be_empty
  end
end
