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
      id: 'tofue',
      displayname: 'Tobias Fuenke',
      mail: 'tofue@nine.ch',
      departments: @departments.dup,
      cancelled?: false
    })

    @management.managers << @person
    @management.people << @person
    @administration.people << @person

    Department.stub(:find) { |id|  @departments.find { |dep| dep.cn == id } }
    Department.stub(:find_all).and_return(@person.departments)
    Person.stub(:find).and_return(@person)
    Person.stub(:find_one).and_return(@person)
    Person.stub(:find_all).and_return([@person])

    LdapSync.all

    @user = User.last
  end

  it 'creates a local user' do
    @user.should_not be_nil
  end

  it 'creates the teams which the user is member of' do
    @person.departments.each do |department|
      Team.find_by_uid(department.id).should_not be_nil
    end
  end

  it 'creates the teams which the user is leading of' do
    Department.find_all.each do |department|
      if department.managers.include?(@person)
        Team.find_by_uid(department.id).should_not be_nil
      end
    end
  end

  it 'assigns the properties of the user correctly' do
    @user.name.should eq(@person.displayname)
  end

  it 'assigns the properties of the teams correctly' do
    @user.teams.each do |team|
      team.name.should eq(Department.find(team.uid).cn)
    end
  end

  it 'removes missing leadership links' do
    team = Team.find_by_uid(@management.id)
    team.has_leader?(@user).should be_true
    @management.managers.delete(@person)
    LdapSync.all
    team.reload
    team.has_leader?(@user).should be_false
  end

  it 'removes missing membership links' do
    team = Team.find_by_uid(@administration.id)
    team.has_member?(@user).should be_true
    @administration.people.delete(@person)
    LdapSync.all
    team.reload
    team.has_member?(@user).should be_false
  end

  it 'detects the change from member to leader' do
    team = Team.find_by_uid(@administration.id)
    team.has_leader?(@user).should be_false
    @administration.managers.push(@person)
    LdapSync.all
    team.reload
    team.has_leader?(@user).should be_true
  end

  it 'deletes "cancelled" persons' do
    User.find_by_uid(@person.id).should_not be_nil
    @person.stub(:cancelled?).and_return(true)
    LdapSync.all
    User.find_by_uid(@person.id).should be_nil
    User.with_deleted.find_by_uid(@person.id).should_not be_nil
  end

end
