require 'spec_helper'

describe SessionsHelper do
  it 'creates the user when signing in' do
    person = Person.find_one
    helper.sign_in(person.id)
    user = User.find_by_ldap_id(person.id).should_not be_nil 
  end
end