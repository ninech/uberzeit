require 'spec_helper'

describe AfterLoginHelper do
  before do
    person = Person.find_one
    helper.sign_in(person.id)
    @user = User.find_by_ldap_id(person.id)
  end

  it 'creates a timesheet for the current user when non-existent' do
    @user.sheets.should_not be_empty
  end

  it 'creates an employment for the current user when non-existent' do
    @user.employments.should_not be_empty
  end
end