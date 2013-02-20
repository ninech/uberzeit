require 'spec_helper'

# Make sure ldap-admin DevelopmentLdapServer is running
describe LdapSync do
  before do
    # Frickelfrickel™
    @management = OpenStruct.new({
      id: 'Management',
      cn: 'Management',
      managers: [],
      people: []
    })

    @administration = OpenStruct.new({
      id: 'Administration',
      cn: 'Administration',
      managers: [],
      people: []
    })
    
    @departments = [@management, @administration]

    @person = OpenStruct.new({
      id: 'hakanns',
      displayname: 'Hans Kanns',
      mail: 'hakanns@mail.ch',
      departments: @departments.dup
    })

    @management.managers << @person
    @management.people << @person
    @administration.people << @person

    Department.stub(:find) do |id| 
      @departments.find { |dep| dep.cn == id }
    end
    Department.stub(:find_all).and_return(@person.departments)
    Person.stub(:find).and_return(@person)
    Person.stub(:find_one).and_return(@person)

    @user = LdapSync.sync_person(@person)
  end

  it 'creates a local user' do
    @user.should_not be_nil
  end

  it 'creates the teams which the user is member of' do
    @person.departments.each do |department|
      Team.find_by_ldap_id(department.id).should_not be_nil
    end
  end

  it 'creates the teams which the user is leading of' do
    Department.find_all.each do |department|
      if department.managers.include?(@person)
        Team.find_by_ldap_id(department.id).should_not be_nil 
      end
    end
  end

  it 'assigns the properties of the user correctly' do
    @user.name.should eq(@person.displayname)
  end

  it 'assigns the properties of the teams correctly' do
    @user.teams.each do |team|
      team.name.should eq(Department.find(team.ldap_id).cn)
    end
  end

  it 'removes missing leadership links' do
    team = Team.find_by_ldap_id(@management.id)
    team.has_leader?(@user).should be_true
    @management.managers.delete(@person)
    LdapSync.sync_person(@person)
    team.reload.has_leader?(@user).should be_false
  end

  it 'removes missing membership links' do
    team = Team.find_by_ldap_id(@administration.id)
    team.has_member?(@user).should be_true
    @administration.people.delete(@person)
    LdapSync.sync_person(@person)
    team.reload.has_member?(@user).should be_false
  end
end